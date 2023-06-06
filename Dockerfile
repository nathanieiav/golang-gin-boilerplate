# Start from golang base image
FROM golang:1.19-alpine

# Set the current working directory inside the container
WORKDIR /app

ENV GO111MODULE="on"
ENV GOOS="linux"
ENV CGO_ENABLED=0
ENV GOFLAGS="-buildvcs=false"

# Install necessary dependencies
RUN apk update \
  && apk add --no-cache \
  ca-certificates \
  curl \
  tzdata \
  git \
  gcc \
  g++ \
  musl-dev \
  && update-ca-certificates

RUN go install github.com/githubnemo/CompileDaemon@latest
RUN go install github.com/pressly/goose/cmd/goose@latest
RUN go install github.com/cosmtrek/air@latest
RUN go install github.com/go-delve/delve/cmd/dlv@latest
RUN go install github.com/swaggo/swag/cmd/swag@v1.8.12
RUN go install github.com/vektra/mockery/v2@latest
RUN go install github.com/google/wire/cmd/wire@latest

EXPOSE 7788
EXPOSE 7789

# Copy the entire project to the working directory
COPY . .

# Build the application
RUN swag init && go build -gcflags='all=-N -l' -o ./tmp/main/engine main.go

ENTRYPOINT ["air", "-c", ".air.toml"]
