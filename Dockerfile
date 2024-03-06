# Stage 1: Build the Go application!
FROM golang:1.21-alpine AS dependencies

WORKDIR /go/src/app

# Copy the Go modules files
COPY go.mod go.sum ./

# Download the dependencies
RUN go mod download

# Stage 2: Compile the code
FROM dependencies as builder

COPY main.go .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/bin/app .

# Stage 3: Create a minimal container for running the application
FROM gcr.io/distroless/static-debian11:nonroot

COPY --from=builder /go/bin/app /
CMD ["/app"]
