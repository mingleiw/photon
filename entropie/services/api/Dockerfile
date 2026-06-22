FROM rust:1.82-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml Cargo.lock ./
COPY services/api/Cargo.toml ./services/api/
COPY services/agent/Cargo.toml ./services/agent/
COPY services/collector/Cargo.toml ./services/collector/
# Stub out other crates so api can build independently
RUN mkdir -p services/agent/src services/collector/src \
    && echo 'fn main() {}' > services/agent/src/main.rs \
    && echo 'fn main() {}' > services/collector/src/main.rs
COPY services/api/src ./services/api/src
COPY services/api/migrations ./services/api/migrations
RUN cargo build --release -p entropie-api

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/entropie-api /usr/local/bin/entropie-api
EXPOSE 8080
CMD ["entropie-api"]
