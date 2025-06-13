# --- Stage 1: Build with Gradle using JDK base ---
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install necessary tools
RUN apk add --no-cache bash curl protobuf

# Copy only what's needed first for cache
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle

# Give Gradle wrapper permission and let it fetch dependencies
RUN chmod +x ./gradlew && ./gradlew --no-daemon downloadRepos || true

# Now copy the rest of the app
COPY . .
COPY ./pb/ ./proto

# Build the project
RUN ./gradlew --no-daemon installDist -PprotoSourceDir=./proto

# --- Stage 2: Runtime using lightweight JRE base ---
FROM eclipse-temurin:21-jre-alpine

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy built app from builder stage
COPY --from=builder /app/build/install/opentelemetry-demo-ad ./build/install/opentelemetry-demo-ad

# Download OpenTelemetry Java agent
ARG OTEL_JAVA_AGENT_VERSION=2.16.0
RUN curl -fsSL -o opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_JAVA_AGENT_VERSION}/opentelemetry-javaagent.jar

ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"

USER appuser

EXPOSE 8080

ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]
