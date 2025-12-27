# Stage 1: Builder
FROM node:18-alpine AS builder

# Remove pre-installed Yarn and install Yarn v1 (matches your yarn.lock)
RUN rm -f /usr/local/bin/yarn && npm install -g yarn@1.22.22

WORKDIR /app

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Install root dependencies using Yarn v1
RUN yarn install --frozen-lockfile

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

# Stage 2: Production
FROM node:18-alpine AS production

WORKDIR /app

# Copy built backend and app from builder
COPY --from=builder /app/packages/backend /app/packages/backend
COPY --from=builder /app/packages/app /app/packages/app
COPY --from=builder /app/plugins /app/plugins

# Install production dependencies only
RUN rm -f /usr/local/bin/yarn && npm install -g yarn@1.22.22 \
    && yarn install --production --frozen-lockfile

# Expose Backstage port
EXPOSE 7007

# Start Backstage
CMD ["node", "packages/backend/dist/index.js"]
