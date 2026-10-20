FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    WORKDIR=/workspace \
    AWS_REGION=us-east-1 \
    S3_PATH=s3://861345371866-us-east-1/ip-32-184-19-170/main.sh

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    jq \
    unzip \
    git \
    awscli \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/bin/bash", "/opt/ml/processing/input/slide.sh"]
