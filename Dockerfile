FROM node:22-alpine AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build


FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src \
    QODER_HOST=0.0.0.0 \
    QODER_PORT=5050

WORKDIR /app

COPY pyproject.toml README.md ./
COPY src/ ./src/
COPY --from=frontend-builder /app/src/qoder2api/static/ ./src/qoder2api/static/

RUN pip install --no-cache-dir .

RUN mkdir -p /root/.qoder

EXPOSE 5050
VOLUME ["/root/.qoder"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5050/healthz', timeout=3).read()" || exit 1

CMD ["python", "-m", "qoder2api.app", "--host", "0.0.0.0", "--port", "5050"]
