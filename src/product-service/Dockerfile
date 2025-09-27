# Uses the official Rust 1.82 image (based on Debian) as the build environment.
# This image has cargo, rustc, and everything needed to compile Rust code.
FROM rust:1.82.0 AS builder

# Creates a new Rust binary project called product-service.
# This step helps cache dependencies: by creating a dummy project, when dependencies are later copied in and built, Docker can reuse cached layers.
RUN USER=root cargo new --bin product-service

# Sets /product-service as the working directory.
WORKDIR /product-service

# Copies the source code from the host machine into the container.
ADD . ./

# Builds the Rust project in release mode (optimized binary).
# The resulting executable will be in target/release/product-service.
RUN cargo build --release

# Create a new stage and copy the binary from the builder stage
# Starts from a minimal Debian image (much smaller than the Rust image).
# This avoids shipping Rust tooling in the final container.
FROM debian:bookworm-slim AS runner

# Sets /app as the working directory for the runtime container.
WORKDIR /app

# Defines a build-time variable (APP_VERSION) that defaults to 0.1.0.
# Can be overridden at build time with --build-arg APP_VERSION=1.2.3.
ARG APP_VERSION=0.1.0

# Installs wget (used for health checks in Docker Compose) and libssl-dev (needed at runtime if the Rust binary depends on OpenSSL).
# Cleans up apt cache to reduce image size.
RUN apt-get update && apt-get install -y wget libssl-dev && rm -rf /var/lib/apt/lists/*

# Copies the compiled binary from the builder stage into /app.
COPY --from=builder /product-service/target/release/product-service /app

# Sets the runtime environment variable APP_VERSION, so the app can read it if needed.
ENV APP_VERSION=$APP_VERSION

# Run the application
# Specifies the default command to run when the container starts: execute the compiled Rust binary.
CMD ["./product-service"]
