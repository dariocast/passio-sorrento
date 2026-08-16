"""
SQLAlchemy models for Passio Sorrento.
"""

from datetime import datetime
from typing import Dict, Any, Optional

from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

from . import db


class Municipality(db.Model):
    """
    Represents a municipality covered by Passio Sorrento (e.g., Sorrento, Sant'Agnello).
    Includes precise GPS coordinates used for meteorological queries and geographical grouping.
    """
    __tablename__ = 'municipalities'

    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    display_order = db.Column(db.Integer, default=0, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationships
    confraternities = db.relationship('Confraternity', backref='municipality_rel', lazy=True)

    def to_dict(self) -> Dict[str, Any]:
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'name': self.name,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'is_active': self.is_active,
            'display_order': self.display_order,
        }

    def __repr__(self) -> str:
        return f'<Municipality {self.name}>'


class AdminUser(UserMixin, db.Model):
    """
    Admin user for the Passio Sorrento Web Management Portal.
    
    Roles:
      - SUPERADMIN: Full control over municipalities, all confraternities, user accounts, and system logs.
      - PRIORE: Scoped control only over their assigned Confraternity and related processions.
    """
    __tablename__ = 'admin_users'

    ROLE_SUPERADMIN = 'SUPERADMIN'
    ROLE_PRIORE = 'PRIORE'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    email = db.Column(db.String(120), nullable=True)
    password_hash = db.Column(db.String(256), nullable=False)
    role = db.Column(db.String(20), default=ROLE_PRIORE, nullable=False)
    confraternity_id = db.Column(db.String(36), db.ForeignKey('confraternities.id'), nullable=True)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def set_password(self, password: str) -> None:
        """Hash and store the password."""
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        """Verify a password against the stored hash."""
        return check_password_hash(self.password_hash, password)

    @property
    def is_superadmin(self) -> bool:
        """Check if user has SUPERADMIN privileges."""
        return self.role == self.ROLE_SUPERADMIN

    @property
    def is_priore(self) -> bool:
        """Check if user is a PRIORE for a specific confraternity."""
        return self.role == self.ROLE_PRIORE

    def can_manage_confraternity(self, confraternity_id: str) -> bool:
        """Verify if this user can manage the given confraternity."""
        if self.is_superadmin:
            return True
        return self.confraternity_id == confraternity_id

    def to_dict(self) -> Dict[str, Any]:
        """Convert user to dictionary representation."""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'role': self.role,
            'confraternity_id': self.confraternity_id,
            'confraternity_name': self.confraternity.name if self.confraternity else None,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }

    def __repr__(self) -> str:
        return f'<AdminUser {self.username} [{self.role}]>'


class Confraternity(db.Model):
    """
    Represents a Confraternity of the Sorrento Peninsula.
    """
    __tablename__ = 'confraternities'
    
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    color = db.Column(db.String(7), nullable=False)  # Hex color, e.g., "#5C1A1B"
    municipality = db.Column(db.String(100), nullable=False)
    municipality_id = db.Column(db.String(36), db.ForeignKey('municipalities.id'), nullable=True)
    coat_of_arms = db.Column(db.String(500), nullable=True)
    history = db.Column(db.Text, nullable=True)
    capofila_secret = db.Column(db.String(64), nullable=True, default='capofila123')
    
    # Relationships
    processions = db.relationship('Procession', backref='confraternity', cascade="all, delete-orphan", lazy=True)
    tracking_logs = db.relationship('TrackingLog', backref='confraternity', cascade="all, delete-orphan", lazy=True)
    priori = db.relationship('AdminUser', backref='confraternity', lazy=True)
    
    def to_dict(self, include_secret: bool = False) -> Dict[str, Any]:
        """Convert model to dictionary for JSON serialization."""
        data = {
            'id': self.id,
            'name': self.name,
            'color': self.color,
            'municipality': self.municipality,
            'municipality_id': self.municipality_id,
            'coat_of_arms': self.coat_of_arms,
            'history': self.history,
        }
        if include_secret:
            data['capofila_secret'] = self.capofila_secret or 'capofila123'
        return data

    def __repr__(self) -> str:
        return f'<Confraternity {self.name}>'


class Procession(db.Model):
    """
    Represents a Holy Week procession event.
    """
    __tablename__ = 'processions'
    
    id = db.Column(db.String(36), primary_key=True)
    confraternity_id = db.Column(db.String(36), db.ForeignKey('confraternities.id'), nullable=False)
    day = db.Column(db.String(50), nullable=False)  # e.g., "Giovedì Santo", "Venerdì Santo"
    exit_time = db.Column(db.DateTime, nullable=False)
    expected_return_time = db.Column(db.DateTime, nullable=True)
    is_live = db.Column(db.Boolean, default=False, nullable=False)
    route_description = db.Column(db.Text, nullable=True)
    
    # Relationships
    tracking_logs = db.relationship('TrackingLog', backref='procession', cascade="all, delete-orphan", lazy=True)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'confraternity_id': self.confraternity_id,
            'day': self.day,
            'exit_time': self.exit_time.isoformat() if self.exit_time else None,
            'expected_return_time': self.expected_return_time.isoformat() if self.expected_return_time else None,
            'is_live': self.is_live,
            'route_description': self.route_description,
        }

    def __repr__(self) -> str:
        return f'<Procession {self.day} - {self.confraternity_id}>'


class TrackingLog(db.Model):
    """
    Unified GPS position log for procession tracking.
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
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert model to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'confraternity_id': self.confraternity_id,
            'procession_id': self.procession_id,
            'lat': self.latitude,
            'lng': self.longitude,
            'last_updated': self.timestamp.isoformat() + 'Z' if self.timestamp else None,
        }

    def __repr__(self) -> str:
        return f'<TrackingLog {self.confraternity_id} ({self.latitude}, {self.longitude})>'
