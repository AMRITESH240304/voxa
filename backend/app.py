# import requests

# response = requests.get(
#     "https://studio-api.cheqd.net/account",
#     headers={
#         "x-api-key": "caas_515ff32ed3ab0617e830ba229b52e3c1cd166ea4d31e7966c1f7025512a3512715cd4e17acfaf86287fac53d79564b0555bea6d963ee0c432b9f1df1c986a70c",
#         "Accept": "*/*"
#     },
# )

# print("Status Code:", response.status_code)
# print("Content-Type:", response.headers.get("Content-Type"))
# print("Raw Text:", response.text[:200])  # Print first 200 characters to avoid flooding

# try:
#     data = response.json()
#     print("JSON Response:", data)
# except requests.exceptions.JSONDecodeError:
#     print("❌ Response is not valid JSON.")

# from resemblyzer import VoiceEncoder, preprocess_wav

# # Load the model (loads once, reuse!)
# encoder = VoiceEncoder()

# # Step 1: Load & preprocess audio
# wav = preprocess_wav('Hebbal Industrial Area.m4a')

# # Step 2: Convert to embedding
# embedding = encoder.embed_utterance(wav)

# # embedding is a 256-d vector (np.ndarray)
# print(embedding)  # 👉 (256,)

import redis
from config import settings

r = redis.Redis(
    host=settings.REDIS_HOST,
    port=settings.REDIS_PORT,
    decode_responses=True,
    username=settings.REDIS_USERNAME,
    password=settings.REDIS_PASSWORD,
)

# # success = r.set('foo', 'bar')
# # True

# r.set('foo', 'bar', ex=10)
result = r.get('audio_embedding')
print(result)

# from resemblyzer import VoiceEncoder, preprocess_wav
# import numpy as np
# import redis
# import json

# # Load the model
# encoder = VoiceEncoder()

# # Load & preprocess audio
# wav = preprocess_wav('Hebbal Industrial Area.m4a')

# # Convert to embedding
# embedding = encoder.embed_utterance(wav)  # numpy array of shape (256,)

# # Convert embedding to a list of regular Python floats
# embedding_list = np.array(embedding, dtype=float).tolist()  # Convert to numpy array with float dtype, then to list

# # Convert list to JSON string
# embedding_json = json.dumps(embedding_list)

# # Connect to Redis
# r = redis.Redis(
#     host=settings.REDIS_HOST,
#     port=settings.REDIS_PORT,
#     decode_responses=True,
#     username=settings.REDIS_USERNAME,
#     password=settings.REDIS_PASSWORD,
# )

# # Store the embedding in Redis with 1-minute expiry
# r.set('audio_embedding', embedding_json, ex=60)

# # Confirm it's stored
# result = r.get('audio_embedding')
# if result is not None:
#     print("Retrieved from Redis:", json.loads(str(result)))  # Convert to str before parsing JSON
# else:
#     print("No data found in Redis")