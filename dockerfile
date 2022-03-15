FROM golang:1.17.7-alpine3.14 as build

RUN mkdir /src

COPY . /src

WORKDIR /src
RUN go mod download && \
    go build -o main . 


FROM alpine:3.14 as base

RUN apk add ca-certificates &&\
    mkdir /app &&\
    adduser -D go-app
COPY  --from=build /test/main /app/main 

RUN  chown -R go-app:go-app /app/
WORKDIR /app
EXPOSE 8080

ENTRYPOINT [ "./main" ]