FROM golang:1.21-alpine AS builder
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
