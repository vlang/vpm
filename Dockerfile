FROM node:15 AS resources
WORKDIR /vpm
RUN npm install -g sass
COPY ./css ./css
COPY ./static ./static
RUN sass ./css/vpm.scss:./static/vpm.css

FROM thevlang/vlang:alpine-dev AS build
WORKDIR /vpm
COPY ./templates ./templates
COPY *.v .
RUN v -prod -o vpm .

FROM thevlang/vlang:alpine-base as app
WORKDIR /vpm
COPY --from=resources /vpm/static ./static
COPY --from=build /vpm/vpm ./vpm
EXPOSE 80
CMD ["./vpm"]