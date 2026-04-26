// const {onRequest} = require("firebase-functions/v2/https");
// const {defineSecret} = require("firebase-functions/params");
// const axios = require("axios");

// // Define secrets
// const CASHFREE_CLIENT_ID = defineSecret("CASHFREE_CLIENT_ID");
// const CASHFREE_CLIENT_SECRET = defineSecret("CASHFREE_CLIENT_SECRET");

// exports.createCashfreeOrder = onRequest(
//     {
//       region: "us-central1",
//       timeoutSeconds: 60,
//       memory: "256MiB",
//       secrets: [CASHFREE_CLIENT_ID, CASHFREE_CLIENT_SECRET],
//     },
//     async (req, res) => {
//       const clientId = process.env.CASHFREE_CLIENT_ID;
//       const clientSecret = process.env.CASHFREE_CLIENT_SECRET;

//       if (!clientId || !clientSecret) {
//         console.error("❌ Missing Cashfree credentials in environment");
//         return res.status(500).json({error: "Missing credentials"});
//       }

//       if (req.method !== "POST") {
//         return res.status(405).json({error: "Method not allowed"});
//       }

//       const data = req.body;
//       const orderId = `order_${Date.now()}`;

//       const body = {
//         order_id: orderId,
//         order_amount: data.amount,
//         order_currency: "INR",
//         customer_details: {
//           customer_id: data.customerId,
//           customer_email: data.customerEmail,
//           customer_phone: data.customerPhone,
//         },
//         order_meta: {
//           return_url: `https://yourapp.com/return?order_id=${orderId}`,
//         },
//       };

//       try {
//         const response = await axios.post("https://api.cashfree.com/pg/orders", body, {
//           headers: {
//             "Content-Type": "application/json",
//             "x-client-id": clientId,
//             "x-client-secret": clientSecret,
//             "x-api-version": "2023-08-01",
//           },
//         });

//         return res.status(200).json({
//           orderId: response.data.order_id,
//           sessionId: response.data.payment_session_id,
//         });
//       } catch (error) {
//         console.error("❌ Cashfree order creation failed:",
//             error.response?.data || error.message);
//         return res.status(500).json({error: "Cashfree order creation failed"});
//       }
//     },
// );
// exports.verifyCashfreePayment = onRequest(
//     {
//       region: "us-central1",
//       timeoutSeconds: 60,
//       memory: "256MiB",
//       secrets: [CASHFREE_CLIENT_ID, CASHFREE_CLIENT_SECRET],
//     },
//     async (req, res) => {
//       const clientId = process.env.CASHFREE_CLIENT_ID;
//       const clientSecret = process.env.CASHFREE_CLIENT_SECRET;

//       if (!clientId || !clientSecret) {
//         console.error("❌ Missing Cashfree credentials in environment");
//         return res.status(500).json({error: "Missing credentials"});
//       }

//       if (req.method !== "POST") {
//         return res.status(405).json({error: "Method not allowed"});
//       }

//       const {orderId} = req.body;

//       if (!orderId) {
//         return res.status(400).json({error: "Missing orderId"});
//       }

//       try {
//         const response = await axios.get(`https://api.cashfree.com/pg/orders/${orderId}`, {
//           headers: {
//             "x-client-id": clientId,
//             "x-client-secret": clientSecret,
//             "x-api-version": "2023-08-01",
//           },
//         });

//         const orderStatus = response.data.order_status;

//         return res.status(200).json({
//           orderId,
//           status: orderStatus, // e.g., "PAID", "ACTIVE", "EXPIRED"
//         });
//       } catch (error) {
//         console.error("❌ Failed to verify Cashfree payment:",
//             error.response?.data || error.message);
//         return res.status(500).json({error: "Failed to verify payment status"});
//       }
//     },
// );





"use strict";

// ─────────────────────────────────────────────────────────────────────────────
// Firebase Functions — thin triggers only
// ALL video processing is offloaded to Cloud Run
// No ffmpeg, no heavy dependencies here
// ─────────────────────────────────────────────────────────────────────────────
const { onRequest }          = require("firebase-functions/v2/https");
const { onObjectFinalized }  = require("firebase-functions/v2/storage");
const { defineSecret }       = require("firebase-functions/params");
const admin                  = require("firebase-admin");
const axios                  = require("axios");

if (!admin.apps.length) {
  admin.initializeApp();
}

// ─────────────────────────────────────────────────────────────────────────────
// Secrets
// ─────────────────────────────────────────────────────────────────────────────
const CASHFREE_CLIENT_ID     = defineSecret("CASHFREE_CLIENT_ID");
const CASHFREE_CLIENT_SECRET = defineSecret("CASHFREE_CLIENT_SECRET");
// Set this after deploying Cloud Run:
//   firebase functions:secrets:set CLOUD_RUN_URL
//   Value: https://zizzle-video-processor-XXXX-uc.a.run.app
const CLOUD_RUN_URL          = defineSecret("CLOUD_RUN_URL");

// =============================================================================
// 1. CASHFREE — createCashfreeOrder (unchanged)
// =============================================================================
exports.createCashfreeOrder = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "256MiB",
    secrets: [CASHFREE_CLIENT_ID, CASHFREE_CLIENT_SECRET],
  },
  async (req, res) => {
    const clientId     = process.env.CASHFREE_CLIENT_ID;
    const clientSecret = process.env.CASHFREE_CLIENT_SECRET;

    if (!clientId || !clientSecret) {
      return res.status(500).json({ error: "Missing credentials" });
    }
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    const data    = req.body;
    const orderId = `order_${Date.now()}`;

    try {
      const response = await axios.post(
        "https://api.cashfree.com/pg/orders",
        {
          order_id:         orderId,
          order_amount:     data.amount,
          order_currency:   "INR",
          customer_details: {
            customer_id:    data.customerId,
            customer_email: data.customerEmail,
            customer_phone: data.customerPhone,
          },
          order_meta: {
            return_url: `https://yourapp.com/return?order_id=${orderId}`,
          },
        },
        {
          headers: {
            "Content-Type":    "application/json",
            "x-client-id":     clientId,
            "x-client-secret": clientSecret,
            "x-api-version":   "2023-08-01",
          },
        }
      );
      return res.status(200).json({
        orderId:   response.data.order_id,
        sessionId: response.data.payment_session_id,
      });
    } catch (error) {
      console.error("❌ Cashfree order failed:", error.response?.data || error.message);
      return res.status(500).json({ error: "Cashfree order creation failed" });
    }
  }
);

// =============================================================================
// 2. CASHFREE — verifyCashfreePayment (unchanged)
// =============================================================================
exports.verifyCashfreePayment = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "256MiB",
    secrets: [CASHFREE_CLIENT_ID, CASHFREE_CLIENT_SECRET],
  },
  async (req, res) => {
    const clientId     = process.env.CASHFREE_CLIENT_ID;
    const clientSecret = process.env.CASHFREE_CLIENT_SECRET;

    if (!clientId || !clientSecret) {
      return res.status(500).json({ error: "Missing credentials" });
    }
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    const { orderId } = req.body;
    if (!orderId) return res.status(400).json({ error: "Missing orderId" });

    try {
      const response = await axios.get(
        `https://api.cashfree.com/pg/orders/${orderId}`,
        {
          headers: {
            "x-client-id":     clientId,
            "x-client-secret": clientSecret,
            "x-api-version":   "2023-08-01",
          },
        }
      );
      return res.status(200).json({ orderId, status: response.data.order_status });
    } catch (error) {
      console.error("❌ Cashfree verify failed:", error.response?.data || error.message);
      return res.status(500).json({ error: "Failed to verify payment status" });
    }
  }
);

// =============================================================================
// 3. TRANSCODE REEL TRIGGER
// Fires when a new video lands in Firebase Storage under reels/
// Does nothing heavy — just calls Cloud Run and returns immediately
// ─────────────────────────────────────────────────────────────────────────────
// Total execution time: ~2 seconds (just an HTTP call)
// No ffmpeg, no memory issues, no timeout risk
// =============================================================================
exports.transcodeReel = onObjectFinalized(
  {
    region:         "us-central1",
    timeoutSeconds: 60,      // only 60s needed — we just fire and forget to Cloud Run
    memory:         "256MiB", // minimal memory — no processing here
    secrets:        [CLOUD_RUN_URL],
  },
  async (event) => {
    const filePath    = event.data.name;
    const bucketName  = event.data.bucket;
    const contentType = event.data.contentType;

    // ── Guards ────────────────────────────────────────────────────
    if (!filePath || !filePath.startsWith("reels/")) return;
    if (!contentType || !contentType.startsWith("video/")) return;

    // Skip already-processed outputs to prevent infinite loop
    if (
      filePath.includes("_720p")       ||
      filePath.includes("_hls")        ||
      filePath.includes("_thumb")      ||
      filePath.startsWith("reels/transcoded/")
    ) {
      console.log("⏭ Skipping processed file:", filePath);
      return;
    }

    // ── Find matching Firestore doc ────────────────────────────────
    const fileName = path.basename(filePath, path.extname(filePath));
    const snap = await admin.firestore()
      .collection("reels")
      .where("videourl", ">=", fileName)
      .where("videourl", "<=", fileName + "\uf8ff")
      .limit(1)
      .get();

    const reelDocId = snap.empty ? null : snap.docs[0].id;
    if (!reelDocId) {
      console.warn("⚠ No Firestore doc found for:", fileName);
    }

    // ── Call Cloud Run — fire and forget ───────────────────────────
    const cloudRunUrl = process.env.CLOUD_RUN_URL;
    if (!cloudRunUrl) {
      console.error("❌ CLOUD_RUN_URL secret not set");
      return;
    }

    try {
      console.log(`📤 Sending to Cloud Run: ${filePath}`);
      await axios.post(
        `${cloudRunUrl}/transcode`,
        { storagePath: filePath, bucketName, reelDocId },
        { timeout: 10000 } // 10s to confirm Cloud Run accepted the job
      );
      console.log("✅ Cloud Run accepted the job");
    } catch (err) {
      console.error("❌ Failed to reach Cloud Run:", err.message);
      if (reelDocId) {
        await admin.firestore()
          .collection("reels")
          .doc(reelDocId)
          .update({ transcodingStatus: "failed" })
          .catch(() => {});
      }
    }
  }
);

// path is needed for basename — lightweight, no ffmpeg
const path = require("path");