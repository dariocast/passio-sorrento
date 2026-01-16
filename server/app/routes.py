"""
API Routes for Holyweek Tracker.
"""

import os
from datetime import datetime
from functools import wraps
from flask import Blueprint, jsonify, request

from . import db
from .models import Confraternity, Procession, Tracking, ProcessionLog

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


@api_bp.route('/processions', methods=['GET'])
def get_processions():
    """
    Get all processions with their confraternity info.
    
    Returns:
        JSON array of procession objects with confraternity details.
    """
    processions = Procession.query.all()
    result = []
    
    for p in processions:
        proc_data = p.to_dict()
        proc_data['confraternity_name'] = p.confraternity.name
        proc_data['confraternity_color'] = p.confraternity.color
        proc_data['municipality'] = p.confraternity.municipality
        result.append(proc_data)
    
    return jsonify(result)


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


# ============================================================================
# ProcessionLog Tracking Endpoints (Simplified for Capofila device)
# ============================================================================

CAPOFILA_SECRET = 'capofila123'


@api_bp.route('/tracking/log', methods=['POST'])
def log_tracking_position():
    """
    Log a new GPS position for a confraternity's procession.
    Uses a simple secret-based authentication for the capofila device.
    
    Expected JSON body:
        {
            "confraternity_id": "uuid",
            "lat": float,
            "lng": float,
            "secret": "capofila123"
        }
    
    Returns:
        JSON object with the logged position data.
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'data': None, 'error': 'No JSON data provided'}), 400
    
    # Simple secret-based auth
    secret = data.get('secret')
    if secret != CAPOFILA_SECRET:
        return jsonify({'data': None, 'error': 'Unauthorized - invalid secret'}), 401
    
    # Validate required fields
    required_fields = ['confraternity_id', 'lat', 'lng']
    for field in required_fields:
        if field not in data:
            return jsonify({'data': None, 'error': f'Missing required field: {field}'}), 400
    
    confraternity_id = data['confraternity_id']
    latitude = data['lat']
    longitude = data['lng']
    
    # Validate confraternity exists
    confraternity = Confraternity.query.get(confraternity_id)
    if not confraternity:
        return jsonify({'data': None, 'error': 'Confraternity not found'}), 404
    
    # Validate coordinates
    if not (-90 <= latitude <= 90 and -180 <= longitude <= 180):
        return jsonify({'data': None, 'error': 'Invalid coordinates'}), 400
    
    # Create new log entry
    log = ProcessionLog(
        confraternity_id=confraternity_id,
        latitude=latitude,
        longitude=longitude,
    )
    db.session.add(log)
    db.session.commit()
    
    return jsonify({'data': log.to_dict(), 'error': None}), 200


@api_bp.route('/tracking/live', methods=['GET'])
def get_live_tracking():
    """
    Get the latest position log for each confraternity that has tracking data.
    
    Returns:
        JSON object with array of latest tracking positions.
        Response format: {"data": [...], "error": null}
    """
    from sqlalchemy import func
    
    # Subquery to get the max timestamp for each confraternity
    subquery = db.session.query(
        ProcessionLog.confraternity_id,
        func.max(ProcessionLog.timestamp).label('max_timestamp')
    ).group_by(ProcessionLog.confraternity_id).subquery()
    
    # Join with the main table to get full records
    latest_logs = db.session.query(ProcessionLog).join(
        subquery,
        db.and_(
            ProcessionLog.confraternity_id == subquery.c.confraternity_id,
            ProcessionLog.timestamp == subquery.c.max_timestamp
        )
    ).all()
    
    # Enrich with confraternity info for map styling
    result = []
    for log in latest_logs:
        log_data = log.to_dict()
        log_data['confraternity_name'] = log.confraternity.name
        log_data['confraternity_color'] = log.confraternity.color
        result.append(log_data)
    
    return jsonify({'data': result, 'error': None})

