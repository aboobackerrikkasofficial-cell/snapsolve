# Multi-stage build for security and size optimization
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim

# Create a non-privileged user to run the app
RUN groupadd -r snapsolve && useradd -r -g snapsolve snapsolve
WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /root/.local /home/snapsolve/.local
COPY . .

# Set environment path
ENV PATH=/home/snapsolve/.local/bin:$PATH

# Harden container
RUN chown -R snapsolve:snapsolve /app
USER snapsolve

EXPOSE 8000

# Use Gunicorn with Uvicorn workers for production stability
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
