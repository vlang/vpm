FROM thevlang/vlang:alpine-dev AS build

ARG args="-prod -gc boehm"
WORKDIR /app

RUN apk --no-cache --update-cache add gc-dev postgresql-dev
COPY . .
RUN v $args -o vpm ./cmd/vpm

FROM thevlang/vlang:alpine-base as app

LABEL maintainer="Anton Zavodchikov <terisbackno@gmail.com>"
WORKDIR /app

RUN apk --no-cache --update-cache add gc-dev postgresql-dev
COPY ./static ./static
COPY ./app/templates ./templates
COPY --from=build /app/vpm ./vpm

EXPOSE 8080
ENTRYPOINT ["./vpm"]
