#!/usr/bin/env python3
"""
Seed script to populate the Passio Sorrento database with real Holy Week data,
including Municipalities with GPS coordinates, Confraternities, Processions,
and SuperAdmin / Priore users.

Credentials are generated dynamically or read from environment variables to ensure
no plain-text secrets are committed to the repository.

Usage: python seed.py
"""

import os
import secrets
import uuid
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Any

from app import create_app, db
from app.models import Municipality, Confraternity, Procession, TrackingLog, AdminUser


def generate_uuid() -> str:
    """Generate a UUID string."""
    return str(uuid.uuid4())


# Real Sorrento Peninsula Municipalities with exact GPS coordinates for weather and mapping
MUNICIPALITIES_DATA = [
    {
        "id": "mun-sorrento",
        "name": "Sorrento",
        "latitude": 40.6263,
        "longitude": 14.3758,
        "display_order": 1,
        "is_active": True,
    },
    {
        "id": "mun-santagnello",
        "name": "Sant'Agnello",
        "latitude": 40.6300,
        "longitude": 14.3986,
        "display_order": 2,
        "is_active": True,
    },
    {
        "id": "mun-pianodisorrento",
        "name": "Piano di Sorrento",
        "latitude": 40.6339,
        "longitude": 14.4086,
        "display_order": 3,
        "is_active": True,
    },
    {
        "id": "mun-meta",
        "name": "Meta",
        "latitude": 40.6419,
        "longitude": 14.4172,
        "display_order": 4,
        "is_active": True,
    },
    {
        "id": "mun-vicoequense",
        "name": "Vico Equense",
        "latitude": 40.6631,
        "longitude": 14.4289,
        "display_order": 5,
        "is_active": True,
    },
    {
        "id": "mun-massalubrense",
        "name": "Massa Lubrense",
        "latitude": 40.6108,
        "longitude": 14.3436,
        "display_order": 6,
        "is_active": True,
    },
]

# Real Confraternity data from Sorrento Peninsula Holy Week
CONFRATERNITIES_DATA = [
    {
        "id": "conf-morte",
        "name": "Arciconfraternita della Morte ed Orazione",
        "color": "#000000",
        "municipality_id": "mun-sorrento",
        "municipality": "Sorrento",
        "coat_of_arms": "/assets/stemmi/morte.png",
        "history": "L'Arciconfraternita della Morte, fondata nel 1606, è una delle più prestigiose della Penisola Sorrentina. I confratelli vestono il tradizionale saio nero e sfilano durante il Venerdì Santo sera portando il Cristo Morto tra i canti del Miserere.",
    },
    {
        "id": "conf-santa-monica",
        "name": "Arciconfraternita di Santa Monica",
        "color": "#FFFFFF",
        "municipality_id": "mun-sorrento",
        "municipality": "Sorrento",
        "coat_of_arms": "/assets/stemmi/santa_monica.png",
        "history": "L'Arciconfraternita di Santa Monica organizza la suggestiva Processione Bianca del Giovedì Santo notte (alle ore 03:00). I confratelli vestono in saio bianco e mantellina nera alla ricerca dei Sepolcri nel silenzio della notte.",
    },
    {
        "id": "conf-addolorata",
        "name": "Arciconfraternita dell'Addolorata",
        "color": "#800080",
        "municipality_id": "mun-sorrento",
        "municipality": "Sorrento",
        "coat_of_arms": "/assets/stemmi/addolorata.png",
        "history": "Istituita nel XVII secolo presso la Cattedrale di Sorrento. I confratelli indossano un saio viola e partecipano alla processione penitenziale con i simboli della Passione.",
    },
    {
        "id": "conf-rosario",
        "name": "Arciconfraternita del SS. Rosario",
        "color": "#FF0000",
        "municipality_id": "mun-meta",
        "municipality": "Meta",
        "coat_of_arms": "/assets/stemmi/rosario.png",
        "history": "L'Arciconfraternita del SS. Rosario di Meta è tra le più vive della costiera. I confratelli sfilano con il tradizionale saio rosso il Giovedì Santo sera lungo le strade del borgo marinaro.",
    },
    {
        "id": "conf-sacramento",
        "name": "Arciconfraternita del SS. Sacramento",
        "color": "#4169E1",
        "municipality_id": "mun-pianodisorrento",
        "municipality": "Piano di Sorrento",
        "coat_of_arms": "/assets/stemmi/sacramento.png",
        "history": "L'Arciconfraternita del SS. Sacramento di Piano di Sorrento custodisce antiche tradizioni eucaristiche. I confratelli vestono con saio blu e mozzetta azzurra.",
    },
    {
        "id": "conf-san-giuseppe",
        "name": "Arciconfraternita di San Giuseppe",
        "color": "#DAA520",
        "municipality_id": "mun-santagnello",
        "municipality": "Sant'Agnello",
        "coat_of_arms": "/assets/stemmi/san_giuseppe.png",
        "history": "Con sede nel rione Maiano a Sant'Agnello, i confratelli indossano il caratteristico saio color oro/giallo e organizzano una sentita e solenne processione del Venerdì Santo.",
    },
    {
        "id": "conf-annunziata",
        "name": "Arciconfraternita della SS. Annunziata",
        "color": "#87CEEB",
        "municipality_id": "mun-vicoequense",
        "municipality": "Vico Equense",
        "coat_of_arms": "/assets/stemmi/annunziata.png",
        "history": "Tra le più antiche della diocesi, i confratelli vestono in saio celeste e mozzetta bianca lungo i vicoli del centro storico a strapiombo sul mare.",
    },
    {
        "id": "conf-carmine",
        "name": "Arciconfraternita del Carmine",
        "color": "#8B4513",
        "municipality_id": "mun-massalubrense",
        "municipality": "Massa Lubrense",
        "coat_of_arms": "/assets/stemmi/carmine.png",
        "history": "Nel cuore dell'antica Massa Lubrense, i confratelli in saio marrone e scapolare carmelitano accompagnano la Vergine verso la Marina della Lobra.",
    },
]


def create_processions(confraternities: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Create procession schedule entries for Holy Week 2026."""
    processions = []
    
    for conf in confraternities:
        if conf["id"] == "conf-santa-monica":
            day = "Giovedì Santo (Notte)"
            exit_time = datetime(2026, 4, 3, 3, 0)
            return_time = datetime(2026, 4, 3, 6, 30)
            route = "Partenza dalla Chiesa di San Vincenzo, Corso Italia, Ospedale, Sepolcri delle Chiese del Centro e rientro all'alba."
        elif conf["id"] == "conf-morte":
            day = "Venerdì Santo (Sera)"
            exit_time = datetime(2026, 4, 3, 20, 30)
            return_time = datetime(2026, 4, 4, 0, 30)
            route = "Chiesa dei Servi di Maria, Via Sersale, Piazza Tasso, Via San Cesareo, Cattedrale dei Santi Filippo e Giacomo e rientro solenne."
        elif conf["id"] == "conf-rosario":
            day = "Giovedì Santo"
            exit_time = datetime(2026, 4, 2, 20, 0)
            return_time = datetime(2026, 4, 3, 1, 0)
            route = "Basilica di Santa Maria del Lauro, Via Caracciolo, Rione Casale, Lungomare e rientro."
        else:
            day = "Venerdì Santo"
            exit_time = datetime(2026, 4, 3, 20, 0)
            return_time = datetime(2026, 4, 4, 0, 0)
            route = "Itinerario storico lungo le vie principali del comune con visita agli Altari della Reposizione."

        processions.append({
            "id": generate_uuid(),
            "confraternity_id": conf["id"],
            "day": day,
            "exit_time": exit_time,
            "expected_return_time": return_time,
            "is_live": False,
            "route_description": route,
        })
    
    return processions


def create_tracking_logs(confraternities: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Create sample GPS logs along real procession routes."""
    tracking_routes = {
        "Sorrento": [
            (40.6263, 14.3758),
            (40.6269, 14.3746),
            (40.6258, 14.3755),
            (40.6256, 14.3761),
            (40.6237, 14.3769),
        ],
        "Meta": [
            (40.6412, 14.4141),
            (40.6415, 14.4155),
            (40.6408, 14.4170),
            (40.6400, 14.4185),
        ],
        "Piano di Sorrento": [
            (40.6334, 14.4242),
            (40.6340, 14.4230),
            (40.6328, 14.4255),
            (40.6310, 14.4280),
        ],
        "Sant'Agnello": [
            (40.6291, 14.3985),
            (40.6285, 14.3998),
            (40.6275, 14.4015),
        ],
        "Vico Equense": [
            (40.6589, 14.4274),
            (40.6582, 14.4260),
            (40.6570, 14.4245),
            (40.6555, 14.4230),
        ],
        "Massa Lubrense": [
            (40.6106, 14.3497),
            (40.6095, 14.3510),
            (40.6080, 14.3525),
        ],
    }
    
    logs = []
    base_time = datetime.now(timezone.utc) - timedelta(hours=1)
    
    for conf in confraternities:
        municipality = conf["municipality"]
        route = tracking_routes.get(municipality, tracking_routes["Sorrento"])
        
        for i, (lat, lng) in enumerate(route):
            log_time = base_time + timedelta(minutes=i * 10)
            logs.append({
                "confraternity_id": conf["id"],
                "latitude": lat,
                "longitude": lng,
                "timestamp": log_time,
            })
    
    return logs


def seed_database():
    """Seed the database with complete initial data."""
    app = create_app()
    
    with app.app_context():
        print("🗑️  Resetting and rebuilding database tables...")
        db.drop_all()
        db.create_all()
        
        # 1. Insert Municipalities
        print("📍 Inserting Municipalities (with GPS coordinates for live weather)...")
        for m_data in MUNICIPALITIES_DATA:
            municipality = Municipality(**m_data)
            db.session.add(municipality)
        db.session.commit()
        print(f"   ✅ Inserted {len(MUNICIPALITIES_DATA)} municipalities")

        # 2. Insert Confraternities
        print("⛪ Inserting Confraternities...")
        for conf_data in CONFRATERNITIES_DATA:
            confraternity = Confraternity(**conf_data)
            db.session.add(confraternity)
        db.session.commit()
        print(f"   ✅ Inserted {len(CONFRATERNITIES_DATA)} confraternities")
        
        # 3. Insert Processions
        print("🕯️  Inserting Processions...")
        processions_data = create_processions(CONFRATERNITIES_DATA)
        for proc_data in processions_data:
            procession = Procession(**proc_data)
            db.session.add(procession)
        db.session.commit()
        print(f"   ✅ Inserted {len(processions_data)} processions")
        
        # 4. Insert sample tracking logs
        print("🛰️  Inserting sample tracking logs...")
        tracking_logs = create_tracking_logs(CONFRATERNITIES_DATA)
        for log_data in tracking_logs:
            log = TrackingLog(**log_data)
            db.session.add(log)
        db.session.commit()
        print(f"   ✅ Inserted {len(tracking_logs)} tracking points")

        # 5. Insert SuperAdmin and Priore Users with dynamic passwords
        print("👑 Creating admin users...")
        
        # Generate or read secure passwords
        superadmin_pwd = os.environ.get("SUPERADMIN_INIT_PWD") or secrets.token_urlsafe(12)
        priore_morte_pwd = os.environ.get("PRIORE_MORTE_PWD") or secrets.token_urlsafe(10)
        priore_monica_pwd = os.environ.get("PRIORE_MONICA_PWD") or secrets.token_urlsafe(10)

        superadmin = AdminUser(
            username="superadmin",
            email="admin@passiosorrento.it",
            role=AdminUser.ROLE_SUPERADMIN,
            is_active=True
        )
        superadmin.set_password(superadmin_pwd)
        db.session.add(superadmin)

        priore_morte = AdminUser(
            username="priore_morte",
            email="morte@passiosorrento.it",
            role=AdminUser.ROLE_PRIORE,
            confraternity_id="conf-morte",
            is_active=True
        )
        priore_morte.set_password(priore_morte_pwd)
        db.session.add(priore_morte)

        priore_monica = AdminUser(
            username="priore_monica",
            email="monica@passiosorrento.it",
            role=AdminUser.ROLE_PRIORE,
            confraternity_id="conf-santa-monica",
            is_active=True
        )
        priore_monica.set_password(priore_monica_pwd)
        db.session.add(priore_monica)

        db.session.commit()
        print("   ✅ Users created with dynamic secure credentials:")
        print(f"      - SuperAdmin:      username 'superadmin'      / password '{superadmin_pwd}'")
        print(f"      - Priore Morte:    username 'priore_morte'    / password '{priore_morte_pwd}'")
        print(f"      - Priore Monica:   username 'priore_monica'   / password '{priore_monica_pwd}'")

        # Summary
        print("\n📊 Database Summary:")
        print(f"   - Comuni: {Municipality.query.count()}")
        print(f"   - Confraternite: {Confraternity.query.count()}")
        print(f"   - Processioni: {Procession.query.count()}")
        print(f"   - Tracking Logs: {TrackingLog.query.count()}")
        print(f"   - Utenti: {AdminUser.query.count()}")
        print("\n✨ Database seeding completed successfully!")


if __name__ == "__main__":
    seed_database()
