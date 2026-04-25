const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const axios = require("axios");

// Define secrets
const CASHFREE_CLIENT_ID = defineSecret("CASHFREE_CLIENT_ID");
const CASHFREE_CLIENT_SECRET = defineSecret("CASHFREE_CLIENT_SECRET");

exports.createCashfreeOrder = onRequest(
    {
      region: "us-central1",
      timeoutSeconds: 60,
      memory: "256MiB",
      secrets: [CASHFREE_CLIENT_ID, CASHFREE_CLIENT_SECRET],
    },
    async (req, res) => {
      const clientId = process.env.CASHFREE_CLIENT_ID;
      const clientSecret = process.env.CASHFREE_CLIENT_SECRET;

      if (!clientId || !clientSecret) {
        console.error("❌ Missing Cashfree credentials in environment");
        return res.status(500).json({error: "Missing credentials"});
      }

      if (req.method !== "POST") {
        return res.status(405).json({error: "Method not allowed"});
      }

      const data = req.body;
      const orderId = `order_${Date.now()}`;

      const body = {
        order_id: orderId,
        order_amount: data.amount,
        order_currency: "INR",
        customer_details: {
          customer_id: data.customerId,
          customer_email: data.customerEmail,
          customer_phone: data.customerPhone,
        },
        order_meta: {
          return_url: `https://yourapp.com/return?order_id=${orderId}`,
        },
      };

      try {
        const response = await axios.post("https://api.cashfree.com/pg/orders", body, {
          headers: {
            "Content-Type": "application/json",
            "x-client-id": clientId,
            "x-client-secret": clientSecret,
            "x-api-version": "2023-08-01",
          },
        });

        return res.status(200).json({
          orderId: response.data.order_id,
          sessionId: response.data.payment_session_id,
        });
      } catch (error) {
        console.error("❌ Cashfree order creation failed:",
            error.response?.data || error.message);
        return res.status(500).json({error: "Cashfree order creation failed"});
      }
    },
);
exports.verifyCashfreePayment = onRequest(
    {
      region: "us-central1",
      timeoutSeconds: 60,
      memory: "256MiB",
      secrets: [CASHFREE_CLIENT_ID, CASHFREE_CLIENT_SECRET],
    },
    async (req, res) => {
      const clientId = process.env.CASHFREE_CLIENT_ID;
      const clientSecret = process.env.CASHFREE_CLIENT_SECRET;

      if (!clientId || !clientSecret) {
        console.error("❌ Missing Cashfree credentials in environment");
        return res.status(500).json({error: "Missing credentials"});
      }

      if (req.method !== "POST") {
        return res.status(405).json({error: "Method not allowed"});
      }

      const {orderId} = req.body;

      if (!orderId) {
        return res.status(400).json({error: "Missing orderId"});
      }

      try {
        const response = await axios.get(`https://api.cashfree.com/pg/orders/${orderId}`, {
          headers: {
            "x-client-id": clientId,
            "x-client-secret": clientSecret,
            "x-api-version": "2023-08-01",
          },
        });

        const orderStatus = response.data.order_status;

        return res.status(200).json({
          orderId,
          status: orderStatus, // e.g., "PAID", "ACTIVE", "EXPIRED"
        });
      } catch (error) {
        console.error("❌ Failed to verify Cashfree payment:",
            error.response?.data || error.message);
        return res.status(500).json({error: "Failed to verify payment status"});
      }
    },
);
