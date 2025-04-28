# Build stage
FROM golang:1.24 AS builder

WORKDIR /app

# Cache dependencies: go.mod & go.sum
COPY go.* ./
RUN go mod download

# Copy source
COPY . .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Production stage
FROM gcr.io/distroless/static:nonroot

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static

EXPOSE 8080

# No shell in distroless, CMD must be JSON array
CMD ["./main"]
