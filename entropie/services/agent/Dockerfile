FROM rust:1.82-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml Cargo.lock ./
COPY services/api/Cargo.toml ./services/api/
COPY services/agent/Cargo.toml ./services/agent/
COPY services/collector/Cargo.toml ./services/collector/
RUN mkdir -p services/api/src services/collector/src services/api/migrations \
    && echo 'fn main() {}' > services/api/src/main.rs \
    && echo 'fn main() {}' > services/collector/src/main.rs
COPY services/agent/src ./services/agent/src
RUN cargo build --release -p entropie-agent

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates kubectl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/entropie-agent /usr/local/bin/entropie-agent
CMD ["entropie-agent"]
