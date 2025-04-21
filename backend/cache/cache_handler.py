from .config.redis_config import RedisConfig
import json

class CacheHandler:
    def __init__(self):
        self.redis = RedisConfig().get_client()

    def cache_embedding(self, embedding_data, expiry=60):
        """
        Cache embedding data with expiry time
        :param embedding_data: numpy array or list to cache
        :param expiry: expiry time in seconds (default 60 seconds)
        """
        try:
            # Convert embedding data to JSON string
            embedding_json = json.dumps(embedding_data)
            return self.redis.set('audio_embedding', embedding_json, ex=expiry)
        except Exception as e:
            print(f"Error caching embedding: {str(e)}")
            return False

    def get_embedding(self):
        """
        Retrieve cached embedding data
        :return: embedding data as list or None if not found
        """
        try:
            result = self.redis.get('audio_embedding')
            if result:
                return json.loads(str(result))
            return None
        except Exception as e:
            print(f"Error retrieving embedding: {str(e)}")
            return None