# ---------- builder ----------
FROM node:20-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN corepack enable && corepack prepare yarn@3.6.4 --activate

# Copy Yarn config + lock first
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# Copy workspace manifests BEFORE install (critical)
COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
# If you have plugins as workspaces, copy their package.json too:
# COPY plugins/<plugin>/package.json plugins/<plugin>/package.json

# Install deps (no --immutable in Docker for now)
RUN yarn install

# Now copy the rest
COPY . .

# Build (order doesn’t matter much, but backend build triggers app sometimes)
RUN yarn workspace backend build
RUN yarn workspace app build

# ---------- runtime ----------
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
