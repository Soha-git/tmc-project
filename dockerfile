#### Building an application ######
FROM golang:1.17.7-alpine3.14 as build

RUN mkdir app
COPY . /go/app
WORKDIR /go/app
RUN go mod download && \
    CGO_ENABLED=0 go build -o main . 

#### Base image #####
FROM alpine:3.14 as base
RUN  apk add --update --no-cache  ca-certificates=~20211220-r0

RUN addgroup appUser &&\
    adduser -S -G appUser appUser &&\
    mkdir /app  

COPY  --from=build /go/app/main /app/main 

RUN  chown -R appUser:appUser /app

WORKDIR /app
USER appUser

ENTRYPOINT [ "./main" ]