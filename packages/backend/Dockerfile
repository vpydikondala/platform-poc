# ---------- builder ----------
FROM node:18-bullseye AS builder

RUN echo "DOCKERFILE_SIGNATURE=2025-12-29-v3"

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-distutils \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
    libssl-dev \
    libffi-dev \
    libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
COPY plugins/ plugins/

RUN set -eux; \
  corepack enable; \
  corepack prepare yarn@3.6.4 --activate; \
  echo "Yarn version: $(yarn -v)"; \
  yarn config set nodeLinker node-modules; \
  yarn config get nodeLinker; \
  yarn install --immutable --inline-builds

COPY . .
RUN yarn workspace backend build && yarn workspace app build


# ---------- runtime ----------
FROM node:18-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

# copy whole built repo (keep your existing behavior)
COPY --from=builder /app /app

EXPOSE 7007

# ✅ DO NOT use yarn at runtime (it will be Yarn 1.x and crash)
# Backstage backend build output is typically here:
CMD ["node", "packages/backend", "--config", "app-config.production.yaml"]
