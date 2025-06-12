# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM python:3.12-alpine3.21 AS build-venv

RUN apk update && \
    apk add gcc g++ linux-headers

COPY requirements.txt requirements.txt

RUN python -m venv venv && \
    venv/bin/pip install --no-cache-dir -r requirements.txt

RUN venv/bin/opentelemetry-bootstrap -a install

FROM python:3.12-alpine3.21


COPY --from=build-venv /venv/ /venv/

WORKDIR /app

COPY demo_pb2_grpc.py demo_pb2_grpc.py
COPY demo_pb2.py demo_pb2.py
COPY logger.py logger.py
COPY metrics.py metrics.py
COPY recommendation_server.py recommendation_server.py

EXPOSE ${RECOMMENDATION_PORT}
ENTRYPOINT [ "/venv/bin/opentelemetry-instrument", "/venv/bin/python", "recommendation_server.py" ]
