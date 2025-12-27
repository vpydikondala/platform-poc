# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Install root dependencies
RUN yarn install --frozen-lockfile

# Copy backend and app package.json separately
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json

# Copy the plugins folder, even if empty
COPY plugins/ plugins/

# Copy remaining source code
COPY packages/backend/ packages/backend/
COPY packages/app/ packages/app/

# Optional: if you have other directories like plugins/<plugin_name>/, copy them as needed
# COPY plugins/<plugin_name>/ plugins/<plugin_name>/

# Install dependencies for backend and app
RUN yarn workspace backend install && yarn workspace app install

# Build the backend and app
RUN yarn workspace backend build && yarn workspace app build

# Stage 2: Production image
FROM node:18-alpine

WORKDIR /app

# Copy built code from builder
COPY --from=builder /app/packages/backend /app/packages/backend
COPY --from=builder /app/packages/app /app/packages/app
COPY --from=builder /app/plugins /app/plugins

# Install production dependencies only
RUN yarn install --production --frozen-lockfile

# Expose Backstage port
EXPOSE 7007

# Start Backstage
CMD ["node", "packages/backend/dist/index.js"]
