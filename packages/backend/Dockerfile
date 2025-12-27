# Stage 1: Builder
FROM node:24-alpine AS builder

# Remove any existing Yarn and install Yarn v1 (matches your yarn.lock)
RUN rm -f /usr/local/bin/yarn /usr/local/bin/yarnpkg \
    && npm install -g yarn@1.22.22

WORKDIR /app

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Install root dependencies using Yarn v1
RUN yarn install --frozen-lockfile

# Copy backend and app package.json separately
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json

# Copy plugins folder
COPY plugins/ plugins/

# Copy remaining source code
COPY packages/backend/ packages/backend/
COPY packages/app/ packages/app/

# Install dependencies for backend and app workspaces
RUN yarn workspace backend install && yarn workspace app install

# Build the backend and app
RUN yarn workspace backend build && yarn workspace app build
