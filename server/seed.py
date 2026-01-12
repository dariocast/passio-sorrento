#!/usr/bin/env python3
"""
Seed script to populate the database with real Sorrento Holy Week data.

Usage: python seed.py
"""

import uuid
from datetime import datetime

from app import create_app, db
from app.models import Confraternity, Procession


def generate_uuid():
    """Generate a UUID string."""
    return str(uuid.uuid4())


# Real Confraternity data from Sorrento Peninsula Holy Week
CONFRATERNITIES_DATA = [
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita della Morte",
        "color": "#000000",
        "municipality": "Sorrento",
        "coat_of_arms": "/assets/stemmi/morte.png",
        "history": "L'Arciconfraternita della Morte, fondata nel 1606, è una delle più antiche e prestigiose confraternite della Penisola Sorrentina. I confratelli vestono con il tradizionale saio nero e incappucciati sfilano durante il Venerdì Santo portando le statue della Passione di Cristo."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita dell'Addolorata",
        "color": "#800080",
        "municipality": "Sorrento",
        "coat_of_arms": "/assets/stemmi/addolorata.png",
        "history": "L'Arciconfraternita dell'Addolorata, istituita nel XVII secolo presso la Cattedrale di Sorrento, venera la Madonna Addolorata. I confratelli indossano un saio viola e partecipano alla processione del Giovedì Santo con le statue dei Misteri."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita di Santa Monica",
        "color": "#FFFFFF",
        "municipality": "Sorrento",
        "coat_of_arms": "/assets/stemmi/santa_monica.png",
        "history": "L'Arciconfraternita di Santa Monica organizza la tradizionale Processione Bianca del Venerdì Santo. I confratelli vestono in bianco e la processione è caratterizzata da un'atmosfera di solennità e raccoglimento."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita del SS. Rosario",
        "color": "#FF0000",
        "municipality": "Meta",
        "coat_of_arms": "/assets/stemmi/rosario.png",
        "history": "L'Arciconfraternita del SS. Rosario di Meta è una delle più attive nella tradizione delle processioni pasquali della costiera. I confratelli indossano un saio rosso e organizzano la processione del Giovedì Santo."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita del SS. Sacramento",
        "color": "#4169E1",
        "municipality": "Piano di Sorrento",
        "coat_of_arms": "/assets/stemmi/sacramento.png",
        "history": "L'Arciconfraternita del SS. Sacramento di Piano di Sorrento custodisce antiche tradizioni religiose. I confratelli vestono con saio blu e partecipano alle processioni del Giovedì e Venerdì Santo."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita di San Giuseppe",
        "color": "#DAA520",
        "municipality": "Sant'Agnello",
        "coat_of_arms": "/assets/stemmi/san_giuseppe.png",
        "history": "L'Arciconfraternita di San Giuseppe, con sede in Sant'Agnello, è dedicata al culto del padre putativo di Gesù. I confratelli indossano un saio color oro/giallo e organizzano una sentita processione pasquale."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita della SS. Annunziata",
        "color": "#87CEEB",
        "municipality": "Vico Equense",
        "coat_of_arms": "/assets/stemmi/annunziata.png",
        "history": "L'Arciconfraternita della SS. Annunziata di Vico Equense è tra le più antiche della diocesi. I confratelli vestono con saio celeste e la processione è accompagnata da canti tradizionali e musiche sacre."
    },
    {
        "id": generate_uuid(),
        "name": "Arciconfraternita del Carmine",
        "color": "#8B4513",
        "municipality": "Massa Lubrense",
        "coat_of_arms": "/assets/stemmi/carmine.png",
        "history": "L'Arciconfraternita del Carmine di Massa Lubrense porta avanti le tradizioni religiose del territorio più occidentale della penisola. I confratelli indossano un saio marrone e la processione attraversa gli antichi borghi marinari."
    },
]

# Procession schedule for Holy Week 2026
def create_processions(confraternities):
    """Create procession entries for each confraternity."""
    processions = []
    
    # Holy Thursday - Giovedì Santo (April 2, 2026)
    holy_thursday = datetime(2026, 4, 2)
    
    # Good Friday - Venerdì Santo (April 3, 2026)
    good_friday = datetime(2026, 4, 3)
    
    for conf in confraternities:
        # Assign procession days based on tradition
        if conf["name"] in ["Arciconfraternita dell'Addolorata", "Arciconfraternita del SS. Rosario"]:
            day = "Giovedì Santo"
            exit_time = datetime(2026, 4, 2, 20, 0)  # 8:00 PM
            return_time = datetime(2026, 4, 3, 2, 0)  # 2:00 AM
        else:
            day = "Venerdì Santo"
            exit_time = datetime(2026, 4, 3, 20, 0)  # 8:00 PM
            return_time = datetime(2026, 4, 4, 3, 0)  # 3:00 AM
        
        processions.append({
            "id": generate_uuid(),
            "confraternity_id": conf["id"],
            "day": day,
            "exit_time": exit_time,
            "expected_return_time": return_time,
            "is_live": False
        })
    
    return processions


def seed_database():
    """Seed the database with initial data."""
    app = create_app()
    
    with app.app_context():
        # Clear existing data
        print("🗑️  Clearing existing data...")
        Procession.query.delete()
        Confraternity.query.delete()
        db.session.commit()
        
        # Insert confraternities
        print("⛪ Inserting confraternities...")
        for conf_data in CONFRATERNITIES_DATA:
            confraternity = Confraternity(**conf_data)
            db.session.add(confraternity)
        db.session.commit()
        print(f"   ✅ Inserted {len(CONFRATERNITIES_DATA)} confraternities")
        
        # Insert processions
        print("🕯️  Inserting processions...")
        processions_data = create_processions(CONFRATERNITIES_DATA)
        for proc_data in processions_data:
            procession = Procession(**proc_data)
            db.session.add(procession)
        db.session.commit()
        print(f"   ✅ Inserted {len(processions_data)} processions")
        
        # Verify data
        print("\n📊 Database Summary:")
        print(f"   - Confraternities: {Confraternity.query.count()}")
        print(f"   - Processions: {Procession.query.count()}")
        
        # List all confraternities
        print("\n📋 Confraternities in database:")
        for conf in Confraternity.query.all():
            print(f"   - {conf.name} ({conf.municipality}) - {conf.color}")
        
        print("\n✨ Database seeding completed successfully!")


if __name__ == "__main__":
    seed_database()
