import redis
from config import settings

class RedisConfig:
    def __init__(self):
        self.redis_client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            decode_responses=True,
            username=settings.REDIS_USERNAME,
            password=settings.REDIS_PASSWORD,
        )
    
    def get_client(self):
        return self.redis_client

    def set_value(self, key, value, expiry=None):
        """Set a value in Redis with optional expiry time in seconds"""
        if expiry:
            return self.redis_client.set(key, value, ex=expiry)
        return self.redis_client.set(key, value)

    def get_value(self, key):
        """Get a value from Redis"""
        return self.redis_client.get(key)

    def delete_value(self, key):
        """Delete a value from Redis"""
        return self.redis_client.delete(key)

    def exists(self, key):
        """Check if a key exists in Redis"""
        return self.redis_client.exists(key)