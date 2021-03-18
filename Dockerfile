FROM thevlang/vlang:alpine-dev AS build
WORKDIR /vpm
COPY ./templates ./templates
COPY *.v .
RUN v -prod -o vpm .

FROM thevlang/vlang:alpine-base as app
WORKDIR /vpm
COPY ./static ./static
COPY --from=build /vpm/vpm ./vpm
EXPOSE 80
CMD ["./vpm"]