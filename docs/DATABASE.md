# Database Schema

The project uses **SQLite** for development and production simplicity.

## Entity Relationship Diagram (Conceptual)

```
[Confraternity] 1 --- * [Procession] 1 --- 0/1 [Tracking]
```

## Tables

### 1. `confraternities`
Stores static information about the religious brotherhoods.

| Column | Type | Description |
|--------|------|-------------|
| `id` | String (PK) | Unique ID (UUID format) |
| `name` | String | Official Name |
| `color` | String | Identifying Hex Color (e.g. #000000) |
| `municipality`| String | Based in (Sorrento, Meta, etc.) |
| `coat_of_arms`| String | URL/Path to image |
| `history` | Text | Historical descriptions |

### 2. `processions`
Links a confraternity to a specific event in the Holy Week calendar.

| Column | Type | Description |
|--------|------|-------------|
| `id` | String (PK) | Unique ID |
| `confraternity_id`| String (FK) | Reference to `confraternities.id` |
| `day` | String | "Giovedì Santo", "Venerdì Santo" etc. |
| `exit_time` | DateTime | Scheduled start |
| `expected_return_time`| DateTime | Scheduled end |
| `is_live` | Boolean | Whether tracking is active |

### 3. `tracking`
Stores the latest coordinates for an active procession.

| Column | Type | Description |
|--------|------|-------------|
| `id` | Integer (PK) | Auto-increment ID |
| `procession_id`| String (FK, Unique) | Reference to `processions.id` |
| `latitude` | Float | GPS Latitude |
| `longitude` | Float | GPS Longitude |
| `timestamp` | DateTime | Creation time |
| `last_update` | DateTime | Last update time |
