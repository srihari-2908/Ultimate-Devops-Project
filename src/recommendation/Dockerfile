# --- Stage 1: Build stage ---
FROM python:3.14.0b2-slim-bookworm AS builder
# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Set workdir
WORKDIR /usr/src/app

# Install dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip \
    && pip install --user --no-cache-dir -r requirements.txt

# Install OpenTelemetry instrumentations
RUN ~/.local/bin/opentelemetry-bootstrap -a install

# Copy app source
COPY . .

# --- Stage 2: Final image ---
FROM python:3.14.0b2-slim-bookworm

ENV PYTHONUNBUFFERED=1
ENV PATH=/root/.local/bin:$PATH
ENV RECOMMENDATION_PORT=1010

# Set workdir
WORKDIR /usr/src/app

# Create non-root user
RUN useradd -m appuser
USER appuser

# Copy dependencies and app code from builder stage
COPY --from=builder /root/.local /root/.local
COPY --from=builder /usr/src/app /usr/src/app

# Run app
ENTRYPOINT ["python", "recommendation_server.py"]