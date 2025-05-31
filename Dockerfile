FROM golang:1.19-alpine AS builder

# Install dependencies
RUN apk add --no-cache git chromium

# Set working directory
WORKDIR /tmp

# Clone WRP repository
RUN git clone https://github.com/tenox7/wrp.git .

# Build the application
RUN go mod tidy && go build -o wrp

# Final stage
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add chromium ca-certificates

# Create non-root user
RUN adduser -D -s /bin/sh wrpuser

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/wrp .

# Change ownership
RUN chown wrpuser:wrpuser /app/wrp

# Switch to non-root user
USER wrpuser

# Expose port
EXPOSE 8080

# Run the application
CMD ["./wrp", "-l", ":8080", "-t", "60"]
