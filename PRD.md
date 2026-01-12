# Product Requirements Document (PRD)

## Project: Sorrento Holy Week Tracker (Codename: "Incappucciati")

### 1. Project Vision
Create a native mobile application (Flutter) supported by a lightweight backend (Python) to digitize the experience of the Holy Week processions in the Sorrento Peninsula. The app serves both local worshippers and tourists, providing historical information, weather context, and, crucially, the real-time location of the processions.

### 2. Domain and Entities
The domain is strictly tied to the Confraternities of the Sorrento Peninsula.

* **Confraternity:** Main entity (e.g., Archconfraternity of Death and Prayer, Confraternity of Our Lady of Sorrows).
  * Attributes: Name, Identifying Color (e.g., Black, Red, Purple), Coat of Arms (SVG/PNG), History, Municipality.
* **Procession:** The specific event associated with a confraternity.
  * Attributes: Day (e.g., Holy Thursday, Good Friday), Exit Time, Expected Return Time.
* **Tracking:** The geographical position.
  * Attributes: Latitude, Longitude, Timestamp, Last Update.

### 3. Software Architecture
The approach must follow **Clean Architecture** to ensure maintainability and testability.

#### A. Mobile App (Flutter)
Layered structure ("Onion Architecture"):
1. **Presentation Layer:** Flutter Widgets, Bloc/Cubit for state management. Design System based on confraternity colors.
2. **Domain Layer:** Pure Entities, Use Cases (e.g., `GetLiveLocationUseCase`, `GetWeatherUseCase`), Repository Interfaces. No external dependencies.
3. **Data Layer:** Repository Implementation, Data Sources (API Client, Local Database).
   * *Map:* Use of `flutter_map` (OpenStreetMap).
   * *Weather:* OpenWeatherMap API integration.

#### B. Backend Server (Python)
Flask micro-framework structured for future horizontal scalability.
1. **API Layer:** Flask Blueprints, OpenAPI definition (Swagger).
2. **Service Layer:** Business logic (coordinate validation, procession session management).
3. **Data Layer:** SQLite for data persistence (easy backup/restore), SQLAlchemy ORM.

### 4. Key Features (MVP)

#### Feature 1: Homepage & Dashboard
* List of upcoming Confraternities/Processions.
* Visual cards with official colors and coats of arms.
* Quick access to "Live" status if a procession is currently active.

#### Feature 2: Weather Section
* Geolocated forecasts for the peninsula municipalities (Sorrento, Sant'Agnello, Piano di Sorrento, Meta).
* Focus on precipitation (crucial for the procession exit).

#### Feature 3: Live Tracking (Core)
* Interactive map (OpenStreetMap).
* Custom marker (confraternity icon) moving in real-time.
* Smart polling to the backend to retrieve updated coordinates.

### 5. Backend API Requirements
* `GET /api/confraternities`: List of static info.
* `GET /api/processions/live`: Gets current coordinates of active processions.
* `POST /api/tracking/update`: (Protected by API Key) Endpoint to send lat/long (to be used by the future "Leader" app).

### 6. Non-Functional Requirements
* **Resilience:** The app must handle connection loss (caching static data).
* **Performance:** The backend must support request spikes during Good Friday.
* **Privacy:** No user data tracked, only procession location (which is public).
