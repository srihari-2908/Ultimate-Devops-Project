# --- Stage 1: Build with Gradle using JDK base ---
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install necessary tools
RUN apk add --no-cache curl bash

# Copy the entire project (safe fix)
COPY . .

# Build the project
RUN chmod +x ./gradlew && ./gradlew installDist -PprotoSourceDir=./proto

# --- Stage 2: Runtime using lightweight JRE base ---
FROM eclipse-temurin:21-jre-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy built application
COPY --from=builder /app/build/install/opentelemetry-demo-ad ./build/install/opentelemetry-demo-ad

# Download OpenTelemetry agent
ARG OTEL_JAVA_AGENT_VERSION=2.16.0
RUN curl -sSL -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar

# Set agent for instrumentation
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"

USER appuser
EXPOSE 8080
ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]
