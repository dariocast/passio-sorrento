# Passio Sorrento — Settimana Santa in Penisola Sorrentina

[![Backend CI & Deploy](https://github.com/dariocast/passio-sorrento/actions/workflows/deploy-server.yml/badge.svg)](https://github.com/dariocast/passio-sorrento/actions/workflows/deploy-server.yml)
[![Landing Deploy](https://github.com/dariocast/passio-sorrento/actions/workflows/deploy-landing.yml/badge.svg)](https://github.com/dariocast/passio-sorrento/actions/workflows/deploy-landing.yml)
[![Mobile App Build](https://github.com/dariocast/passio-sorrento/actions/workflows/build-mobile-app.yml/badge.svg)](https://github.com/dariocast/passio-sorrento/actions/workflows/build-mobile-app.yml)
[![Tracker App Build](https://github.com/dariocast/passio-sorrento/actions/workflows/build-tracker-app.yml/badge.svg)](https://github.com/dariocast/passio-sorrento/actions/workflows/build-tracker-app.yml)

Un ecosistema digitale completo e integrato (App pubblica Flutter, App trasmettitore GPS per i Priori, Backend REST API con Portale Web e Landing Page) per vivere e seguire in tempo reale le processioni della Settimana Santa nella Penisola Sorrentina.

🌐 **Sito Web Ufficiale**: [https://dariocast.github.io/passio-sorrento/](https://dariocast.github.io/passio-sorrento/)  
🖥️ **Portale Admin & API**: [https://passio-sorrento-api.onrender.com/admin](https://passio-sorrento-api.onrender.com/admin)  
📜 **Privacy Policy**: [https://dariocast.github.io/passio-sorrento/privacy.html](https://dariocast.github.io/passio-sorrento/privacy.html)

---

## 🏛️ Struttura del Progetto

```text
passio-sorrento/
├── landing/         # Landing page ufficiale (HTML5, Vanilla CSS Light Theme, JS multilingua)
├── mobile/          # App pubblica Flutter per iOS & Android (Clean Architecture, BLoC, OpenStreetMap)
├── tracker_app/     # App interna Flutter per i Capofila (Android GPS foreground tracking)
├── server/          # Backend Python Flask (PostgreSQL, SQLAlchemy, Flasgger, Admin Dashboard, Rate Limiting)
├── docs/            # Documentazione di sistema (Architettura, API Reference, Database)
├── store_assets/    # Screenshot ufficiali ad alta risoluzione per Google Play ed Apple App Store
└── .github/         # CI/CD Workflows per build, firma crittografica e deploy automatico
```

---

## ✨ Componenti dell'Ecosistema

### 📱 1. App Pubblica (`mobile/`)
* **Mappa GPS Live:** Tracciamento in tempo reale dell'avanzamento dei cortei con i colori ufficiali del saio di ciascuna confraternita.
* **Schede Confraternite:** Stemmi in alta risoluzione caricati dinamicamente, cenni storici, tradizioni dei Miserere e orari di uscita/rientro.
* **Meteo Penisola:** Previsioni meteo orarie e radar precipitazioni in tempo reale via Open-Meteo per tutti i 6 comuni (Sorrento, Piano di Sorrento, Sant'Agnello, Meta, Massa Lubrense, Vico Equense).
* **Resilienza Offline:** Caching locale via SharedPreferences e CachedNetworkImage per consultazione senza connessione.

### 📡 2. App Tracker Capofila (`tracker_app/`)
* **Trasmissione GPS ad Alta Precisione:** Trasmette la posizione della testa del corteo ogni 10/30/60 secondi con autorizzazione `X-Capofila-Secret`.
* **Coda Offline Intelligente:** In caso di perdita momentanea del segnale tra i vicoli storici, accumula le coordinate in memoria locale e le sincronizza automaticamente al ripristino della rete.
* **Distribuzione:** Canale di Test Chiuso su Google Play Console dedicato ai Priori e ai Capofila autorizzati.

### 🖥️ 3. Backend REST API & Admin Portal (`server/`)
* **Motore Flask & PostgreSQL:** Distribuito in cloud su Render con connection pooling e auto-bootstrap database.
* **Sicurezza & Rate Limiting:** Protezione anti-bruteforce (Flask-Limiter) e autenticazione header per i trasmettitori.
* **Portale Amministrativo (`/admin`):** Dashboard responsive per SuperAdmin e Priori per la gestione dei cortei, upload diretto degli stemmi e calendario liturgico completo.
* **Documentazione OpenAPI:** Flasgger / Swagger UI interattivo all'endpoint `/docs`.

### 🌐 4. Landing Page (`landing/`)
* **Design System Light Luxury:** Tipografia e token bordeaux cardinalizio (`#6B1724`) e oro caldo (`#B38F24`) coerenti con l'App Mobile.
* **Mockup Interattivi:** Showcase delle schermate reali dell'applicazione con selettore istantaneo e supporto multilingua (Italiano / Inglese).

---

## 🚀 Avvio Rapido in Locale

### Prerequisiti
* Flutter 3.x+ & Dart SDK
* Python 3.10+
* Android Studio / Xcode per emulazione o dispositivo fisico connesso

### 1. App Mobile
```bash
cd mobile
flutter pub get
flutter run
```

### 2. App Tracker
```bash
cd tracker_app
flutter pub get
flutter run
```

### 3. Backend Server
```bash
cd server
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python seed.py  # Popola il database con dati di test
python run.py   # Avvia il server su http://localhost:5000
```

---

## 🔐 Sicurezza & Firme di Rilascio

Il repository include pipeline GitHub Actions automatizzate che compilano e firmano digitalmente gli artefatti di produzione ad ogni commit su `main`:
* **Android Release Signing:** Keystore crittografico gestito tramite GitHub Secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`).
* **Artefatti Generati:** `passio-sorrento-mobile-aab`, `passio-sorrento-mobile-apk`, `passio-tracker-aab`, `passio-tracker-apk`.

---

## 📚 Documentazione

* [Architettura Software](docs/ARCHITECTURE.md)
* [Specifiche API Reference](docs/API_REFERENCE.md)
* [Schema Database](docs/DATABASE.md)
* [Linee Guida per gli Agenti AI](AGENTS.md)

---

## 📜 Licenza

Distribuito per scopi culturali, comunitari e di valorizzazione delle tradizioni pasquali della Penisola Sorrentina.
