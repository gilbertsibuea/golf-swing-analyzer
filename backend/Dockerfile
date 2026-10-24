# Build
FROM golang:1.22-alpine AS build
WORKDIR /src
RUN apk add --no-cache git ca-certificates
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/golf-backend .

# Run
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=build /out/golf-backend .
ENV PORT=3000 \
    ML_ENGINE_URL=http://ml-engine:8000 \
    CORS_ORIGINS=* \
    TEMP_DIR=/tmp
EXPOSE 3000
CMD ["./golf-backend"]
