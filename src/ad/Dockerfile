# --- Stage 1: Build with Gradle using JDK base ---
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install necessary tools only
RUN apk add --no-cache curl bash

# Copy only files needed for dependency resolution first (for better caching)
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN chmod +x ./gradlew && ./gradlew downloadRepos

# Copy the rest of the source
COPY . .
COPY ./pb/ ./proto

# Build the distribution
RUN ./gradlew installDist -PprotoSourceDir=./proto

# --- Stage 2: Runtime using lightweight JRE base ---
FROM eclipse-temurin:21-jre-alpine

# Use a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy built application
COPY --from=builder /app/build/install/opentelemetry-demo-ad ./build/install/opentelemetry-demo-ad

# Download OpenTelemetry agent safely
ARG OTEL_JAVA_AGENT_VERSION=2.16.0
RUN curl -sSL -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar

# Set Java agent as a runtime option
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"

# Use non-root user
USER appuser

# Use a fixed port or override at runtime
EXPOSE 8080

ENTRYPOINT [ "./build/install/opentelemetry-demo-ad/bin/Ad" ]