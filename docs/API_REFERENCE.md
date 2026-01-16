# API Reference

The backend API is served at `http://localhost:5000/api`.

**Swagger UI**: `http://localhost:5000/docs`  
**OpenAPI JSON**: `http://localhost:5000/apispec.json`

## Authentication

Write operations require authentication:

| Method | Header / Field | Value |
|--------|----------------|-------|
| API Key | `X-API-Key` header | `dev-api-key` |
| Capofila Secret | `secret` in body | `capofila123` |

---

## Endpoints

### Health Check
`GET /health`

Returns server status.

**Response** `200 OK`:
```json
{"status": "healthy", "timestamp": "2026-01-17T00:00:00Z"}
```

---

### Confraternities

#### List All
`GET /confraternities`

**Response** `200 OK`:
```json
[
  {
    "id": "uuid-1",
    "name": "Arciconfraternita della Morte",
    "color": "#000000",
    "municipality": "Sorrento",
    "coat_of_arms": "/assets/stemmi/morte.png",
    "history": "Fondata nel 1606..."
  }
]
```

#### Get by ID
`GET /confraternities/<id>`

**Response** `200 OK`: Single confraternity object  
**Response** `404 Not Found`: `{"error": "Confraternity not found"}`

---

### Processions

#### List All
`GET /processions`

Returns all processions with confraternity info.

**Response** `200 OK`:
```json
[
  {
    "id": "proc-1",
    "confraternity_id": "uuid-1",
    "confraternity_name": "Arciconfraternita della Morte",
    "confraternity_color": "#000000",
    "municipality": "Sorrento",
    "day": "Venerdì Santo",
    "exit_time": "2026-04-18T18:00:00",
    "expected_return_time": "2026-04-19T02:00:00",
    "is_live": false
  }
]
```

#### Live Processions
`GET /processions/live`

Returns only active processions with latest tracking positions.

**Response** `200 OK`:
```json
[
  {
    "confraternity_id": "uuid-1",
    "day": "Venerdì Santo",
    "lat": 40.6263,
    "lng": 14.3758,
    "last_updated": "2026-01-17T00:00:00Z"
  }
]
```

---

### Tracking (TrackingLog)

#### Log Position
`POST /tracking/log`

Log a GPS position from the capofila device.

**Auth**: Requires `secret` in body.

**Request Body**:
```json
{
  "confraternity_id": "uuid-1",
  "lat": 40.6263,
  "lng": 14.3758,
  "secret": "capofila123"
}
```

**Response** `200 OK`:
```json
{
  "data": {
    "id": 1,
    "confraternity_id": "uuid-1",
    "lat": 40.6263,
    "lng": 14.3758,
    "last_updated": "2026-01-17T00:00:00Z"
  },
  "error": null
}
```

**Response** `401 Unauthorized`:
```json
{"data": null, "error": "Unauthorized - invalid secret"}
```

#### Get Live Positions
`GET /tracking/live`

Returns the latest position for each confraternity.

**Response** `200 OK`:
```json
{
  "data": [
    {
      "id": 1,
      "confraternity_id": "uuid-1",
      "confraternity_name": "Arciconfraternita della Morte",
      "confraternity_color": "#000000",
      "lat": 40.6263,
      "lng": 14.3758,
      "last_updated": "2026-01-17T00:00:00Z"
    }
  ],
  "error": null
}
```

---

## Removed Endpoints

The following endpoints were removed during the TrackingLog refactoring:

- ~~`POST /tracking/update`~~ → Use `/tracking/log` instead
- ~~`POST /tracking/stop/<id>`~~ → No longer needed
