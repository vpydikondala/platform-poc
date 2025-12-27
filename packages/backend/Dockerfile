# Stage 1: Builder
FROM node:18-alpine AS builder

# Enable Corepack to use Yarn 4
RUN corepack enable && corepack prepare yarn@4.4.1 --activate

WORKDIR /app

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Install root dependencies
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

# Stage 2: Production image
FROM node:18-alpine

WORKDIR /app

# Copy built code from builder
COPY --from=builder /app/packages/backend /app/packages/backend
COPY --from=builder /app/packages/app /app/packages/app
COPY --from=builder /app/plugins /app/plugins

# Enable Corepack and Yarn 4
RUN corepack enable && corepack prepare yarn@4.4.1 --activate

# Install production dependencies only
RUN yarn install --production --frozen-lockfile

EXPOSE 7007

CMD ["node", "packages/backend/dist/index.js"]
