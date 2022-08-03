# Builder
FROM thevlang/vlang:alpine-dev AS builder

ARG args=""
WORKDIR /vpm
# Install build deps
RUN apk --no-cache --update-cache add gc-dev postgresql-dev
COPY v.mod v.mod
# RUN v install
# Build binary
COPY . .
RUN v $args -o vpm ./cmd/vpm

# Runner
FROM thevlang/vlang:alpine-base

LABEL maintainer="Anton Zavodchikov <terisbackno@gmail.com>"
WORKDIR /vpm
# ? Install runtime deps
RUN apk --no-cache --update-cache add gc-dev postgresql-dev
# Copy binary and assets
COPY ./app/static ./app/static
COPY ./app/templates ./templates
COPY --from=builder /vpm/vpm ./vpm
# Run
EXPOSE 8080
ENTRYPOINT ["./vpm"]
