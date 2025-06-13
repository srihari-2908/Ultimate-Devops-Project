# --- Stage 1: Build the app using JDK base ---
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install minimal tools
RUN apk add --no-cache curl bash

# Copy everything at once (prevents Gradle eval issues)
COPY . .
COPY ./pb/ ./proto

# Build directly
RUN chmod +x ./gradlew && ./gradlew installDist -PprotoSourceDir=./proto

# --- Stage 2: Lightweight JRE runtime image ---
FROM eclipse-temurin:21-jre-alpine

# Add non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only built distribution
COPY --from=builder /app/build/install/opentelemetry-demo-ad ./build/install/opentelemetry-demo-ad

# Download OpenTelemetry agent securely
ARG OTEL_JAVA_AGENT_VERSION=2.16.0
RUN curl -fsSL -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar

# Set Java agent path
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"

# Use non-root user
USER appuser

# Default port (can override via env)
EXPOSE 8080

ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]
