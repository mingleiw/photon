FROM golang:1.22 as build
WORKDIR /src
COPY go.mod go.sum ./
RUN /usr/local/go/bin/go mod download
COPY . .
RUN /usr/local/go/bin/go test ./...
RUN CGO_ENABLED=0 /usr/local/go/bin/go build -o /out/api ./cmd/api

FROM gcr.io/distroless/static:nonroot
COPY --from=build /out/api /api
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/api"]
