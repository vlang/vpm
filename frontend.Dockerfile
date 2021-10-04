FROM node:16-alpine

WORKDIR /app/vpm

# Installing pnpm and using it is 3 times faster than using npm
RUN npm i -g pnpm

# Installing dependencies
COPY package.json package.json
COPY pnpm-lock.yaml pnpm-lock.yaml

RUN pnpm i

COPY src src
COPY static static
COPY svelte.config.js svelte.config.js
COPY tsconfig.json tsconfig.json

RUN pnpm build

# Starts server on :3000
ENTRYPOINT [ "node", "build" ]