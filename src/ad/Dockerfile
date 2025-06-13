# --- Stage 1: Build with Gradle using JDK base ---
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install required tools
RUN apk add --no-cache bash curl protobuf grpc

# Copy only the files needed first (for better Docker cache use)
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle

# Preload dependencies
RUN chmod +x ./gradlew && ./gradlew downloadRepos || true

# Copy the rest of the app source
COPY . .
COPY ./pb/ ./proto

# Ensure GRPC Java plugin is executable
RUN chmod +x /usr/bin/grpc_cpp_plugin

# Build the app (Gradle will pick up installed grpc plugin)
RUN ./gradlew installDist -PprotoSourceDir=./proto


# --- Stage 2: Lightweight JRE runtime image ---
FROM eclipse-temurin:21-jre-alpine

# Create a non-root user for better security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the built application from builder stage
COPY --from=builder /app/build/install/opentelemetry-demo-ad ./build/install/opentelemetry-demo-ad

# Download OpenTelemetry Java Agent
ARG OTEL_JAVA_AGENT_VERSION=2.16.0
RUN curl -fsSL -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar

# Set up instrumentation
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"

# Use non-root user
USER appuser

# Expose the expected app port (can override via docker run -p)
EXPOSE 8080

# Start the app
ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]
