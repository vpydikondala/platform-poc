# Stage 1: Builder
FROM node:24-alpine AS builder

# Install Yarn v4 (latest stable) to match Node 24
RUN npm install -g yarn@4

WORKDIR /app

# Copy all package.json files (root + workspaces)
COPY package.json ./ 
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json
COPY plugins ./plugins

# Install all dependencies (Yarn v4 will generate its own yarn.lock inside container)
RUN yarn install

# Copy the remaining source code
COPY packages/backend/ packages/backend/
COPY packages/app/ packages/app/

# Build backend and app
RUN yarn workspace backend build
RUN yarn workspace app build
