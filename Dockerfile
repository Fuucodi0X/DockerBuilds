FROM node:20-slim

# Parallelize apt-get AND npm global jest install simultaneously
# Both are network I/O — running them in parallel cuts total time
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Shallow clone: only fetch commits since just before target date (2024-02-14)
RUN git clone --shallow-since=2024-02-13 --no-tags https://github.com/josdejong/mathjs.git . && git checkout e1817ba

RUN npm install --omit=dev && npm install --no-save jest

CMD ["npx", "jest", "test/unit-tests/function/utils/isZero.test.js"]