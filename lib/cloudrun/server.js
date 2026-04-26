"use strict";

const express = require("express");
const admin = require("firebase-admin");
const { Storage } = require("@google-cloud/storage");
const ffmpeg = require("fluent-ffmpeg");
const path = require("path");
const os = require("os");
const fs = require("fs");

// ─────────────────────────────────────────────────────────────────────────────
// Init
// ─────────────────────────────────────────────────────────────────────────────
if (!admin.apps.length) {
  admin.initializeApp(); // uses GOOGLE_APPLICATION_CREDENTIALS or ADC automatically on Cloud Run
}

const db = admin.firestore();
const gcs = new Storage();
const app = express();
app.use(express.json());

// ffmpeg uses the real system binary installed via apt in Dockerfile
// No path override needed — it's on $PATH

// ─────────────────────────────────────────────────────────────────────────────
// Health check — Cloud Run requires a 200 on GET /
// ─────────────────────────────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.status(200).json({ status: "ok", service: "zizzle-video-processor" });
});

// ─────────────────────────────────────────────────────────────────────────────
// POST /transcode
// Called by the Cloud Function trigger (index.js) when a new reel is uploaded.
//
// Body:
// {
//   "storagePath": "reels/abc123.mp4",   ← path inside Firebase Storage
//   "bucketName":  "your-project.appspot.com",
//   "reelDocId":   "firestoreDocId"       ← optional, null for migration
// }
// ─────────────────────────────────────────────────────────────────────────────
app.post("/transcode", async (req, res) => {
  const { storagePath, bucketName, reelDocId } = req.body;

  // ── Validate ──────────────────────────────────────────────────────
  if (!storagePath || !bucketName) {
    return res.status(400).json({ error: "storagePath and bucketName are required" });
  }

  console.log(`🎬 Transcode job started — path: ${storagePath}, doc: ${reelDocId}`);

  // Respond immediately so Cloud Function doesn't time out waiting
  // The actual processing continues after this response
  res.status(202).json({ message: "Transcoding started", reelDocId });

  // ── Process in background ─────────────────────────────────────────
  try {
    await transcodeAndSave(bucketName, storagePath, reelDocId);
  } catch (err) {
    console.error("❌ Background transcode failed:", err);
    if (reelDocId) {
      await db.collection("reels").doc(reelDocId)
        .update({ transcodingStatus: "failed" })
        .catch(() => {});
    }
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// POST /migrate
// One-time endpoint to process all existing reels that don't have hlsUrl yet.
// Secured by MIGRATION_TOKEN env variable.
//
// Body:
// {
//   "token":      "YOUR_MIGRATION_TOKEN",
//   "batchSize":  3,
//   "startAfter": "lastDocId"   ← optional, for pagination
// }
// ─────────────────────────────────────────────────────────────────────────────
app.post("/migrate", async (req, res) => {
  // ── Auth check ────────────────────────────────────────────────────
  const { token, batchSize = 3, startAfter = null } = req.body;
  const expectedToken = process.env.MIGRATION_TOKEN;

  if (!expectedToken || token !== expectedToken) {
    console.error("❌ Unauthorized migration attempt");
    return res.status(401).json({ error: "Unauthorized" });
  }

  const bucketName = process.env.FIREBASE_STORAGE_BUCKET;
  if (!bucketName) {
    return res.status(500).json({ error: "FIREBASE_STORAGE_BUCKET env not set" });
  }

  console.log(`🚀 Migration — batchSize: ${batchSize}, startAfter: ${startAfter}`);

  const results = { processed: [], skipped: [], failed: [], nextStartAfter: null };

  try {
    // ── Fetch batch ───────────────────────────────────────────────
    let query = db.collection("reels")
      .where("Audience", "==", "Public")
      .where("Archive", "==", false)
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(parseInt(batchSize, 10));

    if (startAfter) {
      const startDoc = await db.collection("reels").doc(startAfter).get();
      if (startDoc.exists) query = query.startAfter(startDoc);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      return res.status(200).json({
        message: "✅ Migration complete — no more reels to process",
        ...results,
      });
    }

    // ── Process each doc synchronously (stay within Cloud Run timeout) ──
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const reelId = doc.id;

      // Skip already done
      if (data.hlsUrl && data.transcodingStatus === "done") {
        console.log(`⏭ Already done: ${reelId}`);
        results.skipped.push(reelId);
        results.nextStartAfter = reelId;
        continue;
      }

      // Skip in progress
      if (data.transcodingStatus === "processing") {
        console.log(`⏳ In progress: ${reelId}`);
        results.skipped.push(reelId);
        results.nextStartAfter = reelId;
        continue;
      }

      const videourl = data.videourl || "";
      if (!videourl) {
        console.warn(`⚠ No videourl: ${reelId}`);
        results.skipped.push(reelId);
        results.nextStartAfter = reelId;
        continue;
      }

      // ── Resolve Storage path from videourl ──────────────────────
      let storagePath = videourl;
      if (videourl.startsWith("https://")) {
        try {
          const urlObj = new URL(videourl);
          const encodedPath = urlObj.pathname.split("/o/")[1];
          if (encodedPath) {
            storagePath = decodeURIComponent(encodedPath.split("?")[0]);
          }
        } catch (e) {
          console.warn(`⚠ Cannot parse URL for ${reelId}:`, e.message);
          results.failed.push({ id: reelId, error: "Cannot parse videourl" });
          results.nextStartAfter = reelId;
          continue;
        }
      }

      console.log(`🎬 Migrating: ${reelId} — ${storagePath}`);

      try {
        await transcodeAndSave(bucketName, storagePath, reelId);
        results.processed.push(reelId);
      } catch (err) {
        console.error(`❌ Failed: ${reelId}`, err.message);
        await db.collection("reels").doc(reelId)
          .update({ transcodingStatus: "failed" })
          .catch(() => {});
        results.failed.push({ id: reelId, error: err.message });
      }

      results.nextStartAfter = reelId;
    }

    return res.status(200).json({
      message: results.nextStartAfter
        ? `Batch done. Call again with startAfter: "${results.nextStartAfter}" to continue.`
        : "Batch done.",
      ...results,
    });

  } catch (err) {
    console.error("❌ Migration error:", err);
    return res.status(500).json({ error: err.message, ...results });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Core transcode pipeline
// Downloads → H.264 720p faststart → HLS segments → thumbnail → uploads → Firestore
// ─────────────────────────────────────────────────────────────────────────────
async function transcodeAndSave(bucketName, storagePath, reelDocId) {
  const bucket = gcs.bucket(bucketName);
  const reelsRef = db.collection("reels");

  // Unique job id prevents collisions between concurrent jobs
  const jobId = `${path.basename(storagePath, path.extname(storagePath))}_${Date.now()}`;
  const tmpDir = os.tmpdir();

  const inputPath    = path.join(tmpDir, `${jobId}_input.mp4`);
  const out720p      = path.join(tmpDir, `${jobId}_720p.mp4`);
  const outThumb     = path.join(tmpDir, `${jobId}_thumb.jpg`);
  const hlsDir       = path.join(tmpDir, `${jobId}_hls`);
  const hlsPlaylist  = path.join(hlsDir, "index.m3u8");

  fs.mkdirSync(hlsDir, { recursive: true });

  try {
    // Mark as processing
    if (reelDocId) {
      await reelsRef.doc(reelDocId).update({ transcodingStatus: "processing" });
    }

    // ── 1. Download original from Storage ───────────────────────────
    console.log(`⬇ Downloading: ${storagePath}`);
    await bucket.file(storagePath).download({ destination: inputPath });
    const inputSizeMB = (fs.statSync(inputPath).size / 1024 / 1024).toFixed(1);
    console.log(`✅ Downloaded ${inputSizeMB}MB`);

    // ── 2. Encode 720p H.264 + -movflags faststart ──────────────────
    // faststart = MOOV atom moved to front of file
    // This is what makes instant playback possible — player can start
    // rendering before the full file is downloaded
    console.log("🎬 Encoding 720p H.264 with faststart...");
    await runFfmpeg(
      ffmpeg(inputPath)
        .videoCodec("libx264")
        .audioCodec("aac")
        .videoBitrate("1500k")
        .audioBitrate("128k")
        .size("?x720")          // 720p height, preserve aspect ratio
        .autopad()
        .outputOptions([
          "-movflags faststart", // ← MOOV atom at front
          "-preset fast",        // fast encode, good quality
          "-crf 23",             // quality factor (18=best, 28=worst, 23=default)
          "-pix_fmt yuv420p",    // max device compatibility
          "-profile:v baseline", // works on all iOS/Android devices
          "-level 3.1",
        ])
        .output(out720p)
    );
    console.log("✅ 720p done");

    // ── 3. Generate HLS (.m3u8 + .ts segments) ──────────────────────
    // 4-second segments = player can start after downloading just 1 segment
    console.log("📡 Generating HLS...");
    await runFfmpeg(
      ffmpeg(inputPath)
        .videoCodec("libx264")
        .audioCodec("aac")
        .videoBitrate("1500k")
        .audioBitrate("128k")
        .size("?x720")
        .outputOptions([
          "-movflags faststart",
          "-preset fast",
          "-crf 23",
          "-pix_fmt yuv420p",
          "-profile:v baseline",
          "-level 3.1",
          "-hls_time 4",                                              // 4-second segments
          "-hls_list_size 0",                                         // include all segments
          "-hls_segment_filename", path.join(hlsDir, "segment_%03d.ts"),
          "-f hls",
        ])
        .output(hlsPlaylist)
    );
    console.log("✅ HLS done");

    // ── 4. Extract thumbnail JPEG at 1 second ───────────────────────
    console.log("🖼 Extracting thumbnail...");
    await new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .screenshots({
          timestamps: ["00:00:01"],
          filename: `${jobId}_thumb.jpg`,
          folder: tmpDir,
          size: "720x?",
        })
        .on("end", resolve)
        .on("error", reject);
    });
    console.log("✅ Thumbnail done");

    // ── 5. Upload everything to Firebase Storage ─────────────────────
    const baseDest = `reels/transcoded/${jobId}`;

    console.log("⬆ Uploading 720p MP4...");
    const url720 = await uploadToStorage(bucket, out720p, `${baseDest}_720p.mp4`, "video/mp4");

    console.log("⬆ Uploading HLS .ts segments...");
    const tsFiles = fs.readdirSync(hlsDir).filter((f) => f.endsWith(".ts"));
    for (const ts of tsFiles) {
      await uploadToStorage(
        bucket,
        path.join(hlsDir, ts),
        `${baseDest}_hls/${ts}`,
        "video/MP2T"
      );
    }

    // Rewrite relative segment paths in playlist to absolute CDN URLs
    let m3u8Content = fs.readFileSync(hlsPlaylist, "utf-8");
    m3u8Content = m3u8Content.replace(
      /segment_(\d+)\.ts/g,
      `https://storage.googleapis.com/${bucketName}/${baseDest}_hls/segment_$1.ts`
    );
    const updatedPlaylist = path.join(hlsDir, "index_updated.m3u8");
    fs.writeFileSync(updatedPlaylist, m3u8Content);

    console.log("⬆ Uploading HLS playlist...");
    const hlsUrl = await uploadToStorage(
      bucket, updatedPlaylist, `${baseDest}_hls/index.m3u8`, "application/x-mpegURL"
    );

    console.log("⬆ Uploading thumbnail...");
    const thumbUrl = await uploadToStorage(
      bucket, outThumb, `${baseDest}_thumb.jpg`, "image/jpeg"
    );

    // ── 6. Write URLs back to Firestore ─────────────────────────────
    if (reelDocId) {
      await reelsRef.doc(reelDocId).update({
        hlsUrl:           hlsUrl,
        videoUrl_720p:    url720,
        thumbnailUrl:     thumbUrl,
        transcodingStatus: "done",
      });
      console.log(`✅ Firestore updated — ${reelDocId}`);
    }

    console.log(`✅ Job complete: ${jobId}`);
    return { hlsUrl, videoUrl_720p: url720, thumbnailUrl: thumbUrl };

  } finally {
    // Always clean up temp files — Cloud Run disk space is limited
    [inputPath, out720p, outThumb].forEach((f) => {
      try { if (fs.existsSync(f)) fs.unlinkSync(f); } catch (_) {}
    });
    try { fs.rmSync(hlsDir, { recursive: true, force: true }); } catch (_) {}
    console.log("🧹 Temp files cleaned up");
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

function runFfmpeg(command) {
  return new Promise((resolve, reject) => {
    command
      .on("start",    (cmd) => console.log("▶ ffmpeg:", cmd))
      .on("progress", (p)   => { if (p.percent) console.log(`  ${Math.round(p.percent)}%`); })
      .on("end",      ()    => resolve())
      .on("error",    (err) => reject(err))
      .run();
  });
}

async function uploadToStorage(bucket, localPath, destPath, contentType) {
  await bucket.upload(localPath, {
    destination: destPath,
    metadata: {
      contentType,
      cacheControl: "public, max-age=604800", // 7-day CDN edge cache
    },
  });
  await bucket.file(destPath).makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${destPath}`;
}

// ─────────────────────────────────────────────────────────────────────────────
// Start server
// ─────────────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`🚀 Video processor running on port ${PORT}`);
});