# ---------- builder ----------
FROM node:20-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN corepack enable && corepack prepare yarn@3.6.4 --activate

# Copy Yarn config + lock first
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# Install deps (no --immutable and no workspaces focus)
RUN yarn install

# Copy the full repo
COPY . .

# Build
RUN yarn workspace backend build
RUN yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
