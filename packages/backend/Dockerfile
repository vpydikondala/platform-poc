# ---------- builder ----------
FROM node:18-bullseye AS builder

# Helpful to confirm CI uses THIS Dockerfile
RUN echo "DOCKERFILE_SIGNATURE=2025-12-29-v2"

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

# Some node-gyp flows still expect `python` in PATH
RUN ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app

# 1) Yarn Berry / workspace metadata first (cache-friendly)
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/

# 2) Copy workspace manifests BEFORE install
COPY packages/app/package.json packages/app/package.json
COPY packages/backend/package.json packages/backend/package.json
COPY plugins/ plugins/

# 3) Install deps (Yarn 3)
#    - Activate Yarn 3.6.4
#    - Force node-modules linker (avoids PnP + TS compat patch issues)
#    - If install fails, dump native build logs from /tmp
RUN corepack enable \
  && corepack prepare yarn@3.6.4 --activate \
  && echo "Yarn version: $(yarn -v)" \
  && yarn config set nodeLinker node-modules \
  && (yarn install --immutable --inline-builds --json || \
      (echo "==== Yarn install failed; dumping build logs (if any) ====" && \
       find /tmp -maxdepth 3 -name build.log -print -exec cat {} \; || true && \
       echo "==== End build logs ====" && \
       exit 1))

# 4) Copy the rest and build
COPY . .
RUN yarn workspace backend build && yarn workspace app build

# ---------- runtime ----------
FROM node:18-bullseye-slim

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

EXPOSE 7007
CMD ["yarn", "workspace", "backend", "start"]
