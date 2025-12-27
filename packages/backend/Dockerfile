# Stage 1: Builder
FROM node:24-alpine AS builder

# Enable Corepack and activate Yarn 4
RUN corepack enable \
  && corepack prepare yarn@4.4.1 --activate

WORKDIR /app

# Copy root package.json only
COPY package.json ./

# Install root dependencies (will generate yarn.lock inside container)
RUN yarn install

# Copy workspace manifests
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json

# Copy plugins
COPY plugins/ plugins/

# Copy remaining source
COPY packages/backend/ packages/backend/
COPY packages/app/ packages/app/

# Install workspace deps
RUN yarn workspaces focus --all

# Build
RUN yarn workspace backend build \
 && yarn workspace app build
