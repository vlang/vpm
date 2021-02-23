FROM node:15 AS resources
RUN npm install -g sass
COPY ./css ./css
COPY ./static ./static
RUN sass ./css/vpm.scss:./static/vpm.css

FROM thevlang/vlang:buster-dev AS build
COPY ./templates ./templates
COPY *.v .
# RUN v install zztkm.vdotenv
RUN v -prod -o vpm .
COPY --from=resources ./static ./static
EXPOSE 80
CMD ["./vpm"]

# FROM alpine as app
# COPY --from=resources ./static ./static
# COPY --from=build vpm .
# EXPOSE 80
# CMD ["./vpm"]