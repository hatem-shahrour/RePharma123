import json
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List

app = FastAPI()

# Allow CORS for local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

with open("medicine_dataset.json", "r", encoding="utf-8") as f:
    medicines = json.load(f)

@app.get("/search")
def search_medicines(query: str = Query(..., min_length=1)):
    query_lower = query.lower()
    results = [m for m in medicines if query_lower in m["name"].lower() or query_lower in m["activeIngredient"].lower()]
    return results

@app.get("/medicine/{name}")
def get_medicine(name: str):
    for m in medicines:
        if m["name"].lower() == name.lower():
            return m
    raise HTTPException(status_code=404, detail="Medicine not found")

@app.get("/alternatives/{activeIngredient}")
def get_alternatives(activeIngredient: str):
    results = [m for m in medicines if m["activeIngredient"].lower() == activeIngredient.lower()]
    return results
