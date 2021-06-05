FROM thevlang/vlang:alpine-dev AS build
WORKDIR /app
COPY ./templates ./templates
COPY . .
RUN v -prod -gc boehm -o vpm ./cmd/vpm

FROM thevlang/vlang:alpine-base as app
WORKDIR /app
COPY ./static ./static
COPY --from=build /app/vpm ./vpm
EXPOSE 80
CMD ["./vpm"]