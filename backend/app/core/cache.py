"""
Caching configuration for performance optimization
"""
from functools import lru_cache
from typing import Optional
import hashlib
import json


class ResponseCache:
    """
    Simple in-memory cache for API responses
    In production, replace with Redis
    """

    def __init__(self, max_size: int = 1000):
        self.cache = {}
        self.max_size = max_size

    def get(self, key: str) -> Optional[dict]:
        """Get cached value"""
        return self.cache.get(key)

    def set(self, key: str, value: dict, ttl: int = 300):
        """Set cached value with TTL (in seconds)"""
        if len(self.cache) >= self.max_size:
            # Simple LRU: remove first item
            self.cache.pop(next(iter(self.cache)))

        self.cache[key] = {
            "value": value,
            "expires_at": None,  # TODO: Implement TTL
        }

    def delete(self, key: str):
        """Delete cached value"""
        self.cache.pop(key, None)

    def clear(self):
        """Clear all cached values"""
        self.cache.clear()

    @staticmethod
    def generate_cache_key(prefix: str, **kwargs) -> str:
        """Generate cache key from parameters"""
        data = json.dumps(kwargs, sort_keys=True)
        hash_value = hashlib.md5(data.encode()).hexdigest()
        return f"{prefix}:{hash_value}"


# Global cache instance
response_cache = ResponseCache()


# LRU cache for expensive computations
@lru_cache(maxsize=100)
def cached_analysis_prompt(language: str, transcript_hash: str) -> str:
    """Cache analysis prompts (example)"""
    return f"cached_prompt_{language}_{transcript_hash}"
