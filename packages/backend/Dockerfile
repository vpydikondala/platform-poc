# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copy root package.json, yarn.lock, and workspace package.json files
COPY package.json yarn.lock ./
COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
COPY plugins/ plugins/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy full source code
COPY . .

# Build backend and frontend
RUN yarn workspace backend build
RUN yarn workspace app build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app

# Copy built artifacts from builder
COPY --from=builder /app .

# Expose Backstage backend port
EXPOSE 7000

# Set environment variables for production
ENV NODE_ENV=production

# Recommended: let the container read OIDC and DB variables from env at runtime
# These will be provided via Helm values/envsubst in your workflow
ENV BACKSTAGE_AUTH_MODE=oidc
ENV AZURE_CLIENT_ID=""
ENV AZURE_TENANT_ID=""
ENV BACKSTAGE_HOST=""
ENV POSTGRES_HOST=""
ENV POSTGRES_USER=""
ENV POSTGRES_PASSWORD=""
ENV POSTGRES_DB=backstage
ENV TECHDOCS_STORAGE_ACCOUNT=""
ENV TECHDOCS_STORAGE_KEY=""
ENV TECHDOCS_CONTAINER=techdocs
ENV GITHUB_TOKEN=""

# Start the backend
CMD ["node", "packages/backend/dist/index.js"]
