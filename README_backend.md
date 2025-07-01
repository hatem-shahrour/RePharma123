# Medicine Search API Backend

This backend provides a REST API for searching medicines, finding alternatives by active ingredient, and viewing side effects.

## Setup Instructions

1. **Install Python dependencies**

   ```bash
   pip install -r requirements.txt
   ```

2. **Ensure the dataset is present**

   The file `medicine_dataset.json` should be in the same directory as `medicine_api.py`.

3. **Run the API server**

   ```bash
   uvicorn medicine_api:app --reload
   ```
   The API will be available at `http://127.0.0.1:8000`.

## API Endpoints

- `GET /search?query=...`
  - Search medicines by name or active ingredient.
  - Example: `/search?query=paracetamol`

- `GET /medicine/{name}`
  - Get details for a specific medicine by name.
  - Example: `/medicine/Panadol`

- `GET /alternatives/{activeIngredient}`
  - Get all medicines with the same active ingredient.
  - Example: `/alternatives/Paracetamol`

## Notes
- CORS is enabled for all origins (for local development and Flutter integration).
- You can expand `medicine_dataset.json` with more entries as needed.