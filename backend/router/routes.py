from fastapi import APIRouter,UploadFile, File,Header,HTTPException
from config import settings
from cache.cache_handler import CacheHandler
from scipy.spatial.distance import cosine
import numpy as np
import uuid
from resemblyzer import VoiceEncoder, preprocess_wav
from db.db import creatSearch,Mongodb
from datetime import datetime
import httpx
from service.Models import Input
import urllib.parse

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

@router.post("/didCreate/{user_id}/{public_key_hex}")
async def didCreate(user_id: str, public_key_hex: str):

    url = "https://studio-api.cheqd.net/did/create"
    headers = {
        "accept": "application/json",
        "x-api-key": "caas_7f8eace1802a2b150a6f2a72ca1e6919284351595f7170ac02cbd65639ff5664dbeae84b8299774f933d58a8a78d4805e9a0f7cb06d1ee1398ac5874a582cddc",
        "Content-Type": "application/x-www-form-urlencoded"
    }

    # Construct the form data
    form_data = {
        "network": "testnet",
        "identifierFormatType": "uuid",
        "verificationMethodType": "Ed25519VerificationKey2018",
        "service": '[{"idFragment":"service-1","type":"LinkedDomains","serviceEndpoint":["https://example.com"]}]',
        "key": public_key_hex,
        "@context": "https://www.w3.org/ns/did/v1"
    }

    # Encode form data
    encoded_data = urllib.parse.urlencode(form_data)

    try:
        # Set timeout to 60 seconds
        timeout = httpx.Timeout(60.0, connect=10.0)
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(url, headers=headers, content=encoded_data)
    except httpx.RequestError as e:
        raise HTTPException(status_code=500, detail=f"Request error: {str(e)}")

    if response.status_code == 200:
        data = response.json()
        try:
            mongodb.storeDidData(user_id=user_id, did_data=data)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")

        return {
            "message": "DID created and data stored",
            "user_id": user_id,
            "did": data.get("did")
        }
    else:
        raise HTTPException(status_code=response.status_code, detail=response.text)

@router.post("/keyCreate")
async def keyCreate(input:Input):
    url = "https://studio-api.cheqd.net/key/create?type=Ed25519"
    headers = {
        "accept": "application/json",
        "x-api-key": "caas_7f8eace1802a2b150a6f2a72ca1e6919284351595f7170ac02cbd65639ff5664dbeae84b8299774f933d58a8a78d4805e9a0f7cb06d1ee1398ac5874a582cddc"
    }

    timeout = httpx.Timeout(40.0)

    try:
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(url, headers=headers)
    except httpx.ReadTimeout:
        raise HTTPException(status_code=504, detail="Upstream server timed out")

    if response.status_code == 200:
        data = response.json()

        mongodb.updateKidId(user_id=input.userId,kid_id=data.get("kid"),publicKeyHex=data.get("publicKeyHex"))
        return {
            "kid": data.get("kid"),
            "publicKeyHex": data.get("publicKeyHex")
        }
    else:
        raise HTTPException(status_code=response.status_code, detail=response.text)

@router.post("/attachCheqdDid")
async def attachCheqdDid(cheqd_did:str,user_id:str):
   pass