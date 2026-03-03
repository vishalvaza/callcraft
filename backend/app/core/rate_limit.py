"""
Rate limiting middleware for API endpoints
"""
from fastapi import Request, HTTPException, status
from collections import defaultdict
from datetime import datetime, timedelta
from typing import Dict, Tuple


class RateLimiter:
    """
    Simple in-memory rate limiter
    In production, use Redis for distributed rate limiting
    """

    def __init__(self, requests_per_minute: int = 60):
        self.requests_per_minute = requests_per_minute
        self.requests: Dict[str, list[datetime]] = defaultdict(list)

    def is_allowed(self, identifier: str) -> Tuple[bool, int]:
        """
        Check if request is allowed

        Returns:
            Tuple of (is_allowed, remaining_requests)
        """
        now = datetime.utcnow()
        minute_ago = now - timedelta(minutes=1)

        # Clean old requests
        self.requests[identifier] = [
            req_time
            for req_time in self.requests[identifier]
            if req_time > minute_ago
        ]

        # Check limit
        current_requests = len(self.requests[identifier])

        if current_requests >= self.requests_per_minute:
            return False, 0

        # Add current request
        self.requests[identifier].append(now)

        remaining = self.requests_per_minute - (current_requests + 1)
        return True, remaining

    def get_identifier(self, request: Request) -> str:
        """Get identifier from request (IP + user)"""
        # Try to get user ID from auth
        user_id = getattr(request.state, "user_id", None)

        if user_id:
            return f"user:{user_id}"

        # Fallback to IP address
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            return f"ip:{forwarded.split(',')[0]}"

        return f"ip:{request.client.host if request.client else 'unknown'}"


# Global rate limiter
rate_limiter = RateLimiter(requests_per_minute=60)


async def rate_limit_middleware(request: Request, call_next):
    """Rate limiting middleware"""
    identifier = rate_limiter.get_identifier(request)

    is_allowed, remaining = rate_limiter.is_allowed(identifier)

    if not is_allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Rate limit exceeded. Please try again later.",
            headers={"X-RateLimit-Remaining": "0"},
        )

    # Add rate limit headers
    response = await call_next(request)
    response.headers["X-RateLimit-Remaining"] = str(remaining)

    return response
