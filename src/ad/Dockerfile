# --- Stage 1: Build the app with Gradle using JDK base ---
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install only what's necessary
RUN apk add --no-cache curl bash

# Copy files for better build caching
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN chmod +x ./gradlew && ./gradlew downloadRepos

# Copy rest of the app including protobuf files
COPY . .
COPY ./pb/ ./proto

# Build the app distribution
RUN ./gradlew installDist -PprotoSourceDir=./proto

# --- Stage 2: Lightweight Runtime using JRE base ---
FROM eclipse-temurin:21-jre-alpine

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only built output
COPY --from=builder /app/build/install/opentelemetry-demo-ad ./build/install/opentelemetry-demo-ad

# Download the OpenTelemetry Java Agent
ARG OTEL_JAVA_AGENT_VERSION=2.16.0
RUN curl -fsSL -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar

# Set Java agent for instrumentation
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"

# Use non-root user for better container security
USER appuser

# Expose default app port (override via env if needed)
EXPOSE 8080

# Start the application
ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]
