FROM golang:1.21.3-alpine AS builder
# RUN apk add  --no-cache --update git curl bash
WORKDIR /app
ADD go.mod go.sum ./
RUN go mod download
ADD . .
ENV CGO_ENABLED=0 \
    GOOS=linux
RUN go build -o gqbooks .

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/gqbooks .
ADD res /app/res
CMD ["/app/gqbooks"]
