FROM node:24-alpine AS builder

RUN corepack enable \
 && corepack prepare yarn@4.4.1 --activate

WORKDIR /app

COPY package.json ./
RUN yarn install

COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json
COPY plugins/ plugins/
COPY packages/backend/ packages/backend/
COPY packages/app/ packages/app/

RUN yarn workspaces focus --all
RUN yarn workspace backend build && yarn workspace app build
