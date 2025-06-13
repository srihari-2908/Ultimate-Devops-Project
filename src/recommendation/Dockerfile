# Stage 1: Build dependencies
FROM python:3.12-alpine3.21 AS builder

# Install only necessary build tools and clean up
RUN apk add --no-cache gcc g++ linux-headers libffi-dev musl-dev

# Set up virtual environment and install dependencies
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt && \
    /venv/bin/opentelemetry-bootstrap -a install

# Stage 2: Final minimal image
FROM python:3.12-alpine3.21

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy pre-built virtualenv from builder
COPY --from=builder /venv /venv

# Set working directory
WORKDIR /app

# Copy only application code
COPY demo_pb2_grpc.py demo_pb2.py logger.py metrics.py recommendation_server.py ./

USER appuser
EXPOSE 50051

# Run the application with instrumentation
ENTRYPOINT ["/venv/bin/opentelemetry-instrument", "/venv/bin/python", "recommendation_server.py"]