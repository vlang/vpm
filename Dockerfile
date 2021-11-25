FROM thevlang/vlang:alpine-dev AS build

WORKDIR /app

RUN apk --no-cache add gc-dev postgresql-dev
COPY . .
RUN v -prod -gc boehm -o vpm ./cmd/vpm

FROM thevlang/vlang:alpine-base as app

LABEL maintainer="Anton Zavodchikov <terisbackno@gmail.com>"
WORKDIR /app

RUN apk --no-cache add gc-dev postgresql-dev
COPY ./static ./static
COPY --from=build /app/vpm ./vpm

EXPOSE 8080
ENTRYPOINT ["./vpm"]
