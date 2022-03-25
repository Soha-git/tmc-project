FROM golang:1.17.7-alpine3.14 as build

RUN mkdir app
COPY . /go/app
WORKDIR /go/app
RUN go mod download && \
    CGO_ENABLED=0 go build -o main . 


FROM alpine:3.14 as base

RUN addgroup go-app &&\
    adduser -S -G go-app go-app
RUN apk add ca-certificates=~20211220-r0 &&\
    mkdir /app  
COPY  --from=build /go/app/main /app/main 

RUN  chown -R go-app:go-app /app

WORKDIR /app

ENTRYPOINT [ "./main" ]