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
    
    # Relationships
    processions = db.relationship('Procession', backref='confraternity', lazy=True)
    tracking_logs = db.relationship('TrackingLog', backref='confraternity', lazy=True)
    
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
    
    # Relationships
    tracking_logs = db.relationship('TrackingLog', backref='procession', lazy=True)
    
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


class TrackingLog(db.Model):
    """
    Unified GPS position log for procession tracking.
    
    Each entry represents a single GPS position update from a capofila device.
    The latest entry per confraternity represents the current position.
    Historical entries are preserved for route replay/analysis.
    """
    __tablename__ = 'tracking_logs'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    confraternity_id = db.Column(db.String(36), db.ForeignKey('confraternities.id'), nullable=False)
    procession_id = db.Column(db.String(36), db.ForeignKey('processions.id'), nullable=True)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Index for efficient "latest position" queries
    __table_args__ = (
        db.Index('idx_tracking_confraternity_timestamp', 'confraternity_id', 'timestamp'),
    )
    
    def to_dict(self):
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'confraternity_id': self.confraternity_id,
            'procession_id': self.procession_id,
            'lat': self.latitude,
            'lng': self.longitude,
            'last_updated': self.timestamp.isoformat() + 'Z' if self.timestamp else None,
        }

