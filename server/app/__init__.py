"""
Flask Application Factory for Holyweek Tracker API.
"""

import os
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flasgger import Swagger

# Initialize extensions
db = SQLAlchemy()

# Swagger/OpenAPI configuration
swagger_config = {
    "headers": [],
    "specs": [
        {
            "endpoint": "apispec",
            "route": "/apispec.json",
            "rule_filter": lambda rule: True,
            "model_filter": lambda tag: True,
        }
    ],
    "static_url_path": "/flasgger_static",
    "swagger_ui": True,
    "specs_route": "/docs"
}

swagger_template = {
    "info": {
        "title": "Holyweek Tracker API",
        "description": "REST API for the Sorrento Holy Week Tracker application. Provides endpoints for confraternities, processions, and live GPS tracking.",
        "version": "1.0.0",
        "contact": {
            "name": "Dario Castellano",
            "url": "https://dariocast.xyz"
        },
        "license": {
            "name": "MIT",
            "url": "https://opensource.org/licenses/MIT"
        }
    },
    "servers": [
        {
            "url": "http://localhost:5000/api",
            "description": "Local development server"
        }
    ],
    "tags": [
        {"name": "Health", "description": "Server health check"},
        {"name": "Confraternities", "description": "Confraternity data endpoints"},
        {"name": "Processions", "description": "Procession schedule endpoints"},
        {"name": "Tracking", "description": "Live GPS tracking endpoints"}
    ],
    "components": {
        "securitySchemes": {
            "ApiKeyAuth": {
                "type": "apiKey",
                "in": "header",
                "name": "X-API-Key",
                "description": "API key for protected endpoints"
            }
        },
        "schemas": {
            "Confraternity": {
                "type": "object",
                "properties": {
                    "id": {"type": "string", "format": "uuid"},
                    "name": {"type": "string"},
                    "color": {"type": "string", "pattern": "^#[0-9A-Fa-f]{6}$"},
                    "municipality": {"type": "string"},
                    "coat_of_arms": {"type": "string", "nullable": True},
                    "history": {"type": "string", "nullable": True}
                }
            },
            "Procession": {
                "type": "object",
                "properties": {
                    "id": {"type": "string", "format": "uuid"},
                    "confraternity_id": {"type": "string", "format": "uuid"},
                    "day": {"type": "string"},
                    "exit_time": {"type": "string", "format": "date-time"},
                    "expected_return_time": {"type": "string", "format": "date-time", "nullable": True},
                    "is_live": {"type": "boolean"}
                }
            },
            "TrackingPosition": {
                "type": "object",
                "properties": {
                    "id": {"type": "integer"},
                    "confraternity_id": {"type": "string", "format": "uuid"},
                    "confraternity_name": {"type": "string"},
                    "confraternity_color": {"type": "string"},
                    "lat": {"type": "number", "format": "float"},
                    "lng": {"type": "number", "format": "float"},
                    "last_updated": {"type": "string", "format": "date-time"}
                }
            }
        }
    }
}


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
    Swagger(app, config=swagger_config, template=swagger_template)
    
    # Register blueprints
    from .routes import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    return app

