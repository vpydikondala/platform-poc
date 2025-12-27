# ---------- builder ----------
FROM node:20-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare yarn@3.6.4 --activate
WORKDIR /app

# Yarn PnP + plugins + lockfile first
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/plugins .yarn/plugins
COPY .yarn/plugins .yarn/plugins

# Install (allow scripts; native modules will build here)
RUN yarn install --immutable

# Copy sources and build
COPY . .
RUN yarn workspaces focus --all
RUN yarn workspace backend build && yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

# Copy only what we need to run
COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
