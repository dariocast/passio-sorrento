# API Reference

The backend API is served at `http://localhost:5000/api`.

## Authentication

Write operations (POST/PUT/DELETE) require an API Key passed in the headers.

- **Header Name**: `X-API-Key`
- **Default Key (Dev)**: `dev-api-key`

## Endpoints

### 1. Health Check
`GET /health`
- **Purpose**: Verify the server is running.
- **Response**: `200 OK`
```json
{
  "status": "healthy",
  "timestamp": "2026-01-12T22:00:00Z"
}
```

### 2. List Confraternities
`GET /confraternities`
- **Purpose**: Get all static info about confraternities.
- **Response**: `200 OK`
```json
[
  {
    "id": "uuid-1",
    "name": "Arciconfraternita della Morte",
    "color": "#000000",
    "municipality": "Sorrento",
    "coat_of_arms": "url/to/image.png",
    "history": "Fondato nel..."
  }
]
```

### 3. Get Live Tracking
`GET /processions/live`
- **Purpose**: Retrieve the real-time position of all active processions.
- **Response**: `200 OK`
```json
[
  {
    "procession_id": "proc-1",
    "latitude": 40.6263,
    "longitude": 14.3758,
    "timestamp": "iso-time",
    "last_update": "iso-time",
    "confraternity_id": "uuid-1",
    "day": "Venerdì Santo"
  }
]
```

### 4. Update Tracking Position
`POST /tracking/update`
- **Auth**: Required (API Key)
- **Body**:
```json
{
  "procession_id": "proc-1",
  "latitude": 40.6263,
  "longitude": 14.3758
}
```
- **Response**: `200 OK` returns the updated tracking object.

### 5. Stop Tracking
`POST /tracking/stop/<procession_id>`
- **Auth**: Required (API Key)
- **Purpose**: Stop the live status of a procession.
- **Response**: `200 OK`
```json
{
  "message": "Tracking stopped",
  "procession_id": "proc-1"
}
```
