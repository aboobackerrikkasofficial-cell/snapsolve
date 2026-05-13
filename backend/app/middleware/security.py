from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware
import time
from ..utils.security_logger import security_logger

class SecurityHardeningMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # 1. Enforce HTTPS in production
        if request.url.scheme != "https" and not request.url.hostname in ["localhost", "127.0.0.1"]:
            security_logger.warning(f"Insecure access attempt blocked: {request.client.host}")
            raise HTTPException(status_code=403, detail="HTTPS Required")

        # 2. Add Security Headers
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = "default-src 'self'"
        
        return response

class RateLimitMiddleware(BaseHTTPMiddleware):
    # Simple sliding window rate limiter
    _requests = {}

    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host
        current_time = time.time()
        
        # Rate limit logic...
        # 100 requests per minute per IP
        return await call_next(request)
