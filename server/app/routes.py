"""
API Routes for Holyweek Tracker.
"""

import os
from datetime import datetime
from functools import wraps
from flask import Blueprint, jsonify, request

from . import db
from .models import Confraternity, Procession, Tracking

api_bp = Blueprint('api', __name__)


def require_api_key(f):
    """
    Decorator to protect endpoints with API key authentication.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        expected_key = os.environ.get('API_KEY', 'dev-api-key')
        
        if not api_key or api_key != expected_key:
            return jsonify({'error': 'Unauthorized', 'message': 'Invalid or missing API key'}), 401
        
        return f(*args, **kwargs)
    return decorated


@api_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})


@api_bp.route('/confraternities', methods=['GET'])
def get_confraternities():
    """
    Get all confraternities.
    
    Returns:
        JSON array of confraternity objects.
    """
    confraternities = Confraternity.query.all()
    return jsonify([c.to_dict() for c in confraternities])


@api_bp.route('/confraternities/<confraternity_id>', methods=['GET'])
def get_confraternity(confraternity_id):
    """
    Get a single confraternity by ID.
    
    Args:
        confraternity_id: The confraternity's unique identifier.
    
    Returns:
        JSON object of the confraternity or 404 error.
    """
    confraternity = Confraternity.query.get_or_404(confraternity_id)
    return jsonify(confraternity.to_dict())


@api_bp.route('/processions/live', methods=['GET'])
def get_live_processions():
    """
    Get all currently live processions with their tracking data.
    
    Returns:
        JSON array of live tracking objects.
    """
    live_processions = Procession.query.filter_by(is_live=True).all()
    result = []
    
    for procession in live_processions:
        if procession.tracking:
            tracking_data = procession.tracking.to_dict()
            tracking_data['confraternity_id'] = procession.confraternity_id
            tracking_data['day'] = procession.day
            result.append(tracking_data)
    
    return jsonify(result)


@api_bp.route('/tracking/update', methods=['POST'])
@require_api_key
def update_tracking():
    """
    Update tracking data for a procession.
    Protected by API key.
    
    Expected JSON body:
        {
            "procession_id": "uuid",
            "latitude": float,
            "longitude": float
        }
    
    Returns:
        JSON object with the updated tracking data.
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'Bad Request', 'message': 'No JSON data provided'}), 400
    
    required_fields = ['procession_id', 'latitude', 'longitude']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': 'Bad Request', 'message': f'Missing required field: {field}'}), 400
    
    procession_id = data['procession_id']
    latitude = data['latitude']
    longitude = data['longitude']
    
    # Validate coordinates
    if not (-90 <= latitude <= 90 and -180 <= longitude <= 180):
        return jsonify({'error': 'Bad Request', 'message': 'Invalid coordinates'}), 400
    
    # Find or create tracking record
    tracking = Tracking.query.filter_by(procession_id=procession_id).first()
    
    if tracking:
        tracking.latitude = latitude
        tracking.longitude = longitude
        tracking.last_update = datetime.utcnow()
    else:
        # Verify procession exists
        procession = Procession.query.get(procession_id)
        if not procession:
            return jsonify({'error': 'Not Found', 'message': 'Procession not found'}), 404
        
        tracking = Tracking(
            procession_id=procession_id,
            latitude=latitude,
            longitude=longitude,
        )
        db.session.add(tracking)
        
        # Mark procession as live
        procession.is_live = True
    
    db.session.commit()
    
    return jsonify(tracking.to_dict()), 200


@api_bp.route('/tracking/stop/<procession_id>', methods=['POST'])
@require_api_key
def stop_tracking(procession_id):
    """
    Stop tracking for a procession.
    Protected by API key.
    
    Args:
        procession_id: The procession's unique identifier.
    
    Returns:
        JSON object with success message.
    """
    procession = Procession.query.get_or_404(procession_id)
    procession.is_live = False
    db.session.commit()
    
    return jsonify({'message': 'Tracking stopped', 'procession_id': procession_id})
