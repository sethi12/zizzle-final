# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Builder — install npm dependencies only
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-slim AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: Runtime — real ffmpeg binary from apt, no npm ffmpeg wrapper needed
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-slim

# Install ffmpeg (full build — H.264, AAC, HLS all included)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Verify ffmpeg is available
RUN ffmpeg -version | head -1

WORKDIR /app

# Copy dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY . .

# Cloud Run always uses PORT env variable
ENV PORT=8080
ENV NODE_ENV=production

EXPOSE 8080

CMD ["node", "server.js"]