# Use Node 18 as the builder base image (Node 20 causes build issues with isolated-vm)
FROM node:18-bullseye AS builder

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

# Install dependencies (allow scripts; native modules will build here)
RUN yarn install --inline-builds

# Copy sources and build
COPY . . 
RUN yarn workspace backend build && yarn workspace app build

# Use Node 18 for runtime as well (to match the builder version)
FROM node:18-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

# Copy only necessary files from the builder stage
COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
