# Make the Python version into a variable so that it may be updated easily if / when needed.
ARG pythonVersion=3.9

# Builder stage: install build deps and Python wheels once
FROM python:${pythonVersion}-slim AS builder
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*
COPY ./requirements.txt /app/
RUN pip install --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage: slim image with only runtime deps
FROM python:${pythonVersion}-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /install /usr/local
COPY ./app.py ./config.py ./run.py /app/
COPY ./api/ /app/api/
COPY ./migrations/ /app/migrations/
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
CMD ["python", "run.py"]
