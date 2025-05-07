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