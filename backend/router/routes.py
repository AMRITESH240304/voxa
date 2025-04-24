from fastapi import APIRouter,UploadFile, File,Header,HTTPException
from config import settings
from cache.cache_handler import CacheHandler
from scipy.spatial.distance import cosine
import numpy as np
import uuid
from resemblyzer import VoiceEncoder, preprocess_wav
from db.db import creatSearch,Mongodb
from datetime import datetime
mongodb = Mongodb()
router = APIRouter()
cache = CacheHandler()
encoder = VoiceEncoder()
print(settings.REDIS_HOST)

@router.get("/hello")
def say_hello():
    return {"message": "Hello from another route!"}

@router.post("/collectVoice")
async def voice(
    file: UploadFile = File(...),
    user_id: str = Header(..., description="Unique identifier for the user")
):
    try:
        if not user_id:
            raise HTTPException(status_code=400, detail="User ID is required")

        audio_bytes = await file.read()
        with open("temp_audio.wav", "wb") as f:
            f.write(audio_bytes)
        wav = preprocess_wav("temp_audio.wav")

        current_embedding = np.array(encoder.embed_utterance(wav)).tolist()

        cached = cache.get_embedding(user_id)

        if not cached:
            initial_data = {
                "voices": [current_embedding],
                "count": 1
            }
            cache.cache_embedding(user_id, initial_data, expiry=600)
            return {"message": "Voice 1 stored"}

        cached_voices = cached["voices"]
        count = cached["count"]
        last_embedding = cached_voices[-1]
        similarity = 1 - cosine(np.array(current_embedding), np.array(last_embedding))

        if similarity >= 0.8:
            cached_voices.append(current_embedding)
            count += 1
            
            updated_data = {
                "voices": cached_voices,
                "count": count
            }
            cache.cache_embedding(user_id, updated_data, expiry=600)

            if count >= 5:
                try:
                    mongodb.store_embeddings(user_id, cached_voices, count)
                    return {"message": "Collected 5 similar voices. Embeddings stored in MongoDB."}
                except Exception as e:
                    raise HTTPException(status_code=500, detail=str(e))
            
            return {"message": f"Voice {count} stored with similarity {similarity:.2f}"}
        else:
            return {"message": f"Voice rejected. Similarity {similarity:.2f} < 0.80"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/getEmbedding")
async def getEmbedding():
    creatSearch()
    return {"message": "success"}