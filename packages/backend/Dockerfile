# ---------- builder ----------
FROM node:20-bullseye AS builder

# Add the deadsnakes PPA to install newer Python versions
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    make \
    g++ \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*
# Set python3.11 as the default Python version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

WORKDIR /app

# (optional) signature so you can confirm CI uses THIS Dockerfile
RUN echo "DOCKERFILE_SIGNATURE=2025-12-28-v1"

# Copy Yarn Berry files first
COPY package.json yarn.lock .yarnrc.yml ./ 
COPY .yarn/ .yarn/

# Copy workspace manifests BEFORE install
COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
COPY plugins/ plugins/

# Use Yarn 3 via corepack, then install with Yarn 3 flags only
RUN corepack enable \
  && corepack prepare yarn@3.6.4 --activate \
  && echo "Yarn version: $(yarn -v)" \
  && yarn install --immutable --inline-builds

# Copy the rest and build
COPY . .
RUN yarn workspace backend build && yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
