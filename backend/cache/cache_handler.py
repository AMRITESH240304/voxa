from .config.redis_config import RedisConfig
import json

class CacheHandler:
    def __init__(self):
        self.redis = RedisConfig().get_client()

    def cache_embedding(self, user_id, embedding_data, expiry=60):
        """
        Cache embedding data with expiry time
        :param user_id: unique identifier for the user
        :param embedding_data: numpy array or list to cache
        :param expiry: expiry time in seconds (default 60 seconds)
        """
        try:
            embedding_json = json.dumps(embedding_data)
            key = f'audio_embedding:{user_id}'
            return self.redis.set(key, embedding_json, ex=expiry)
        except Exception as e:
            print(f"Error caching embedding: {str(e)}")
            return False

    def get_embedding(self, user_id):
        """
        Retrieve cached embedding data
        :param user_id: unique identifier for the user
        :return: embedding data as list or None if not found
        """
        try:
            key = f'audio_embedding:{user_id}'
            result = self.redis.get(key)
            if result:
                return json.loads(str(result))
            return None
        except Exception as e:
            print(f"Error retrieving embedding: {str(e)}")
            return None