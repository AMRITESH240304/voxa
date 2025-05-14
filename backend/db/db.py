from pymongo import MongoClient
import certifi
from config import settings
from pymongo.operations import SearchIndexModel

uri = settings.MONGO_URI

def creatSearch():
    client = MongoClient(uri, tlsCAFile=certifi.where())
    db = client.get_database("voxa")  # Replace with your DB name
    collection = db.get_collection("newcollection")
    vector_index = SearchIndexModel(
    definition={
        "fields": [
            {
                "type": "vector",
                "numDimensions": 256,  # Specify the vector size
                "path": "embedding",  # Replace with the field containing your vectors
                "similarity": "cosine"  # Choose from "euclidean", "cosine", or "dotProduct"
            }
        ]
    },
    name="vector_index_256",  # Name of the index
    type="vectorSearch"
    )

    collection.create_search_index(model=vector_index)



class Mongodb:
    def __init__(self):
        self.client = MongoClient(settings.MONGO_URI, tlsCAFile=certifi.where())
        self.db = self.client["voxa"]
        self.collection = self.db["users"]

    def store_embeddings(self, user_id: str, embeddings: list, count: int):
        try:
            self.collection.update_one(
                {"user_id": user_id},
                {
                    "$set": {
                        "voice_embeddings": embeddings,
                        "embedding_count": count,
                    }
                },
                upsert=True
            )
            return True
        except Exception as e:
            raise Exception(f"Failed to store embeddings: {str(e)}")

    def updateKidId(self, user_id: str, kid_id: str,publicKeyHex:str):
        try:
            self.collection.update_one(
                {"user_id": user_id},
                {
                    "$set": {
                        "kid_id": kid_id,
                        "publicKeyHex":publicKeyHex
                    }
                },
                upsert=True
            )
            return True
        except Exception as e:
            raise Exception(f"Failed to store embeddings: {str(e)}")

    def get_public_key(self, user_id: str = None) -> dict:
        try:
            query = {"user_id": user_id} if user_id else {}
            doc = self.collection.find_one(query, sort=[("_id", -1)])
            if not doc or "publicKeyHex" not in doc:
                raise Exception("No valid publicKeyHex found.")
            return {
                "publicKeyHex": doc["publicKeyHex"],
                "user_id": doc.get("user_id"),
                "kid_id": doc.get("kid_id")
            }
        except Exception as e:
            raise Exception(f"Failed to fetch publicKeyHex: {str(e)}")
    
    def storeDidData(self, user_id: str, did_data: dict):
        try:
            self.collection.update_one(
                {"user_id": user_id},
                {
                    "$set": {
                        "did": did_data.get("did"),
                        "controller": did_data.get("controller"),
                        "services": did_data.get("services", []),
                        "keys": did_data.get("keys", [])
                    }
                },
                upsert=True
            )
            return True
        except Exception as e:
            raise Exception(f"Failed to store DID data: {str(e)}")

    def get_did_data(self, user_id: str) -> dict:
        try:
            doc = self.collection.find_one({"user_id": user_id}, sort=[("_id", -1)])
            if not doc or "did" not in doc:
                raise Exception("No valid DID data found.")
            return {
                "did": doc["did"],
                "embedding_count": doc.get("voice_embeddings"),
            }
        except Exception as e:
            raise Exception(f"Failed to fetch DID data: {str(e)}")
