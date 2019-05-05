# build with compiler
FROM golang:alpine AS build
WORKDIR /app
ADD . /app
RUN cd /app && go build -o server

# build without compiler
FROM alpine
RUN apk update && \
    apk add ca-certificates && \
    rm -rf /var/cache/apk/* 
WORKDIR /app
COPY --from=build /app/server /app

EXPOSE 8080
ENTRYPOINT ./server