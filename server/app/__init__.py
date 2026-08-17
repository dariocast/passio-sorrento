"""
Flask Application Factory for Holyweek Tracker API.
"""

import os
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect
from flasgger import Swagger


def _load_env(dotenv_path: str = '.env') -> None:
    """Load key-value pairs from a .env file into os.environ."""
    if os.path.exists(dotenv_path):
        with open(dotenv_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, val = line.split('=', 1)
                    key = key.strip()
                    val = val.strip().strip('\'"')
                    if key not in os.environ:
                        os.environ[key] = val

_load_env()


# Initialize extensions
db = SQLAlchemy()
login_manager = LoginManager()
csrf = CSRFProtect()

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
    db_url = os.environ.get('DATABASE_URL', 'sqlite:///holyweek.db')
    if db_url.startswith('postgres://'):
        db_url = db_url.replace('postgres://', 'postgresql://', 1)

    app.config['SQLALCHEMY_DATABASE_URI'] = db_url
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key')
    
    # Override with provided config
    if config:
        app.config.update(config)
    
    # Initialize extensions
    db.init_app(app)
    CORS(app)
    csrf.init_app(app)
    Swagger(app, config=swagger_config, template=swagger_template)

    # Flask-Login setup
    login_manager.login_view = 'admin.login'
    login_manager.login_message_category = 'error'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(user_id: str):
        from .models import AdminUser
        return AdminUser.query.get(int(user_id))
    
    # Register API blueprint (CSRF-exempt so external clients work)
    from .routes import api_bp
    csrf.exempt(api_bp)
    app.register_blueprint(api_bp, url_prefix='/api')

    # Register Admin blueprint
    from .admin import admin_bp
    app.register_blueprint(admin_bp)
    
    # Create database tables and auto-bootstrap if empty
    with app.app_context():
        db.create_all()
        try:
            from .models import Municipality
            if Municipality.query.first() is None:
                # Auto-bootstrap initial dataset
                import seed
                seed.seed_database()
        except Exception as e:
            app.logger.warning(f"Database bootstrap notice: {e}")
    
    return app


