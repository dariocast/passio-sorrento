"""
Flask Application Factory for Holyweek Tracker API.
"""

import os
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

# Initialize extensions
db = SQLAlchemy()


def create_app(config=None):
    """
    Application factory pattern.
    
    Args:
        config: Optional configuration dictionary to override defaults.
    
    Returns:
        Configured Flask application instance.
    """
    app = Flask(__name__)
    
    # Default configuration
    app.config.setdefault('SQLALCHEMY_DATABASE_URI', 
                          os.environ.get('DATABASE_URL', 'sqlite:///holyweek.db'))
    app.config.setdefault('SQLALCHEMY_TRACK_MODIFICATIONS', False)
    app.config.setdefault('SECRET_KEY', os.environ.get('SECRET_KEY', 'dev-secret-key'))
    
    # Override with provided config
    if config:
        app.config.update(config)
    
    # Initialize extensions
    db.init_app(app)
    CORS(app)
    
    # Register blueprints
    from .routes import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    return app
