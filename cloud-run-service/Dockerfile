FROM golang:1.16.3 AS builder

COPY GCSProxy /GCSProxy
WORKDIR /GCSProxy
RUN go build -o /app

FROM gcr.io/distroless/base-debian10

WORKDIR /
COPY --from=builder /app .

CMD ["/app"]
