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

# 1) Yarn Berry / PnP files first (so installs are reproducible)
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# 2) IMPORTANT: copy workspace manifests BEFORE yarn install
#    (otherwise Yarn doesn't know about workspaces like packages/app)
COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
# If you have local plugins, include their package.json too
COPY plugins/ plugins/

# 3) Install deps
RUN corepack enable && corepack prepare yarn@3.6.4 --activate \
  && yarn install --inline-builds

# 4) Copy the rest of the source and build
COPY . .
RUN yarn workspace backend build && yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
