# ---------- builder ----------
FROM node:20-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
    libssl-dev \
    libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Yarn Berry / PnP files first
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# Copy workspace manifests BEFORE install
COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
COPY plugins/ plugins/

# Install deps (Yarn 3)
RUN corepack enable \
  && corepack prepare yarn@3.6.4 --activate \
  && echo "Yarn version: $(yarn -v)" \
  && yarn install --immutable --inline-builds --json

# Copy rest + build
COPY . .
RUN yarn workspace backend build && yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
