# ── Parallel stage: pre-install jest (BuildKit runs this concurrently) ──
FROM node:20-slim AS jest-deps
WORKDIR /jest
RUN npm init -y > /dev/null 2>&1 && \
    npm install jest --no-audit --no-fund

# ── Main stage ──
FROM node:20-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone, checkout, and install prod deps in one layer (fewer layers = faster export)
RUN git clone --shallow-since=2024-02-13 --no-tags https://github.com/josdejong/mathjs.git . && \
    git checkout e1817ba && \
    npm install --omit=dev --no-audit --no-fund

# Merge pre-installed jest into node_modules (no overlap with mathjs prod deps)
COPY --from=jest-deps /jest/node_modules/ ./node_modules/

CMD ["npx", "jest", "test/unit-tests/function/utils/isZero.test.js"]