# Stage 1: Builder
FROM node:18-alpine AS builder

# Enable Corepack and Yarn 4
RUN corepack enable && corepack prepare yarn@4.4.1 --activate

WORKDIR /app

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Install root dependencies using Yarn 4 immutable mode
RUN yarn install --immutable

# Copy backend and app package.json separately
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json

# Copy the plugins folder from repo root
COPY plugins/ plugins/

# Copy remaining source code
COPY packages/backend/ packages/backend/
COPY packages/app/ packages/app/

# Install dependencies for backend and app
RUN yarn workspace backend install && yarn workspace app install

# Build the backend and app
RUN yarn workspace backend build && yarn workspace app build
