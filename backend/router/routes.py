from fastapi import APIRouter,UploadFile, File
from config import settings
from cache.cache_handler import CacheHandler
from scipy.spatial.distance import cosine
import numpy as np
import uuid
from resemblyzer import VoiceEncoder, preprocess_wav
router = APIRouter()
cache = CacheHandler()
encoder = VoiceEncoder()
print(settings.REDIS_HOST)

@router.get("/hello")
def say_hello():
    return {"message": "Hello from another route!"}

@router.post("/collectVoice")
async def voice(file: UploadFile = File(...)):
    try:
        audio_bytes = await file.read()
        with open("temp_audio.wav", "wb") as f:
            f.write(audio_bytes)
        wav = preprocess_wav("temp_audio.wav")

        current_embedding = np.array(encoder.embed_utterance(wav)).tolist()

        cached = cache.get_embedding()

        if not cached:
            initial_data = {
                "voices": [current_embedding],
                "count": 1
            }
            cache.cache_embedding(initial_data, expiry=3600)
            return {"message": "Voice 1 stored"}

        cached_voices = cached["voices"]
        count = cached["count"]
        last_embedding = cached_voices[-1]
        similarity = 1 - cosine(np.array(current_embedding), np.array(last_embedding))

        if similarity >= 0.8:
            # Add current embedding
            cached_voices.append(current_embedding)
            count += 1
            
            updated_data = {
                "voices": cached_voices,
                "count": count
            }
            cache.cache_embedding(updated_data, expiry=3600)

            if count >= 5:
                return {"message": "Collected 5 similar voices. Process complete."}
            return {"message": f"Voice {count} stored with similarity {similarity:.2f}"}
        else:
            return {"message": f"Voice rejected. Similarity {similarity:.2f} < 0.80"}

    except Exception as e:
        return {"error": str(e)}