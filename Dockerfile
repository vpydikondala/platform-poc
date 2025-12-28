# ---------- builder ----------
FROM node:20-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev build-essential pkg-config git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN corepack enable && corepack prepare yarn@3.6.4 --activate

# Copy only dependency metadata first (better layer caching)
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# Install dependencies (allow scripts; native modules will build here)
RUN yarn install  # <-- removed --immutable here

# Copy source and build
COPY . .
RUN yarn workspace backend build && yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
