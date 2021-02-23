FROM node:15 AS resources
RUN npm install -g sass
WORKDIR /vpm/
COPY ./css ./css
COPY ./static ./static
RUN sass ./css/vpm.scss:./static/vpm.css

FROM thevlang/vlang:buster-dev AS build
WORKDIR /vpm/
COPY ./templates ./templates
COPY *.v .
RUN v -prod -o vpm .

FROM alpine as app
COPY --from=resources /vpm/static ./static
COPY --from=build /vpm/vpm .
EXPOSE 80
CMD ["./vpm"]