"""
SQLAlchemy models for Holyweek Tracker.
"""

from datetime import datetime
from . import db


class Confraternity(db.Model):
    """
    Represents a Confraternity of the Sorrento Peninsula.
    """
    __tablename__ = 'confraternities'
    
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    color = db.Column(db.String(7), nullable=False)  # Hex color, e.g., "#000000"
    municipality = db.Column(db.String(100), nullable=False)
    coat_of_arms = db.Column(db.String(500), nullable=True)
    history = db.Column(db.Text, nullable=True)
    
    # Relationship
    processions = db.relationship('Procession', backref='confraternity', lazy=True)
    
    def to_dict(self):
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'name': self.name,
            'color': self.color,
            'municipality': self.municipality,
            'coat_of_arms': self.coat_of_arms,
            'history': self.history,
        }


class Procession(db.Model):
    """
    Represents a Holy Week procession event.
    """
    __tablename__ = 'processions'
    
    id = db.Column(db.String(36), primary_key=True)
    confraternity_id = db.Column(db.String(36), db.ForeignKey('confraternities.id'), nullable=False)
    day = db.Column(db.String(50), nullable=False)  # e.g., "Holy Thursday"
    exit_time = db.Column(db.DateTime, nullable=False)
    expected_return_time = db.Column(db.DateTime, nullable=True)
    is_live = db.Column(db.Boolean, default=False)
    
    # Relationship
    tracking = db.relationship('Tracking', backref='procession', uselist=False, lazy=True)
    
    def to_dict(self):
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'confraternity_id': self.confraternity_id,
            'day': self.day,
            'exit_time': self.exit_time.isoformat() if self.exit_time else None,
            'expected_return_time': self.expected_return_time.isoformat() if self.expected_return_time else None,
            'is_live': self.is_live,
        }


class Tracking(db.Model):
    """
    Represents live tracking data for a procession.
    """
    __tablename__ = 'tracking'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    procession_id = db.Column(db.String(36), db.ForeignKey('processions.id'), nullable=False, unique=True)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    last_update = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert model to dictionary for JSON serialization."""
        return {
            'procession_id': self.procession_id,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'timestamp': self.timestamp.isoformat() if self.timestamp else None,
            'last_update': self.last_update.isoformat() if self.last_update else None,
        }


class ProcessionLog(db.Model):
    """
    Stores historical GPS position logs for procession tracking.
    Each entry represents a single position update from the capofila device.
    """
    __tablename__ = 'procession_logs'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    confraternity_id = db.Column(db.String(36), db.ForeignKey('confraternities.id'), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationship
    confraternity = db.relationship('Confraternity', backref=db.backref('logs', lazy=True))
    
    def to_dict(self):
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'confraternity_id': self.confraternity_id,
            'lat': self.latitude,
            'lng': self.longitude,
            'last_updated': self.timestamp.isoformat() + 'Z' if self.timestamp else None,
        }
