# App building stage
FROM node:17-alpine AS builder

WORKDIR /app

# Installing pnpm, it's faster for us, and takes less space
RUN npm i -g pnpm

# Installing deps
COPY package.json pnpm-lock.yaml /app/
RUN pnpm i

# Building node server
COPY . .
RUN pnpm run build

# App running stage
FROM node:17-alpine
LABEL maintainer="Anton Zavodchikov <terisbackno@gmail.com>"

WORKDIR /app

RUN apk --no-cache add git ca-certificates

# Copying node server and manifest
COPY --from=builder /app/package.json .
COPY --from=builder /app/build .

ENTRYPOINT [ "node", "./index.js" ]

EXPOSE 3000
