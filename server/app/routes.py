"""
API Routes for Holyweek Tracker.
"""

import os
from datetime import datetime
from functools import wraps
from flask import Blueprint, jsonify, request

from . import db
from .models import Municipality, Confraternity, Procession, TrackingLog

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
    """Server health check
    ---
    tags:
      - Health
    responses:
      200:
        description: Server is healthy
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: string
                  example: healthy
                timestamp:
                  type: string
                  format: date-time
    """
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})


@api_bp.route('/municipalities', methods=['GET'])
def get_municipalities():
    """Get all active municipalities
    ---
    tags:
      - Municipalities
    responses:
      200:
        description: List of all active municipalities with GPS coordinates
        content:
          application/json:
            schema:
              type: array
              items:
                type: object
                properties:
                  id:
                    type: string
                  name:
                    type: string
                  latitude:
                    type: number
                  longitude:
                    type: number
                  is_active:
                    type: boolean
                  display_order:
                    type: integer
    """
    municipalities = Municipality.query.filter_by(is_active=True).order_by(
        Municipality.display_order, Municipality.name
    ).all()
    return jsonify([m.to_dict() for m in municipalities])


@api_bp.route('/municipalities/<municipality_id>', methods=['GET'])
def get_municipality(municipality_id):
    """Get a single municipality by ID
    ---
    tags:
      - Municipalities
    parameters:
      - in: path
        name: municipality_id
        schema:
          type: string
        required: true
        description: Unique identifier of the municipality
    responses:
      200:
        description: Single municipality details
      404:
        description: Municipality not found
    """
    municipality = Municipality.query.get(municipality_id)
    if not municipality:
        return jsonify({'error': 'Municipality not found'}), 404
    return jsonify(municipality.to_dict())


@api_bp.route('/confraternities', methods=['GET'])
def get_confraternities():
    """Get all confraternities
    ---
    tags:
      - Confraternities
    responses:
      200:
        description: List of all confraternities
        content:
          application/json:
            schema:
              type: array
              items:
                $ref: '#/components/schemas/Confraternity'
    """
    confraternities = Confraternity.query.all()
    return jsonify([c.to_dict() for c in confraternities])


@api_bp.route('/confraternities/<confraternity_id>', methods=['GET'])
def get_confraternity(confraternity_id):
    """Get a single confraternity by ID
    ---
    tags:
      - Confraternities
    parameters:
      - in: path
        name: confraternity_id
        schema:
          type: string
          format: uuid
        required: true
        description: Unique identifier of the confraternity
    responses:
      200:
        description: Confraternity details
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Confraternity'
      404:
        description: Confraternity not found
    """
    confraternity = Confraternity.query.get_or_404(confraternity_id)
    return jsonify(confraternity.to_dict())


@api_bp.route('/processions', methods=['GET'])
def get_processions():
    """Get all processions with confraternity info
    ---
    tags:
      - Processions
    responses:
      200:
        description: List of all processions with confraternity details
        content:
          application/json:
            schema:
              type: array
              items:
                allOf:
                  - $ref: '#/components/schemas/Procession'
                  - type: object
                    properties:
                      confraternity_name:
                        type: string
                      confraternity_color:
                        type: string
                      municipality:
                        type: string
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
    """Get currently live processions with tracking data
    ---
    tags:
      - Processions
    responses:
      200:
        description: List of live processions with current positions
        content:
          application/json:
            schema:
              type: array
              items:
                type: object
                properties:
                  procession_id:
                    type: string
                  confraternity_id:
                    type: string
                  day:
                    type: string
                  latitude:
                    type: number
                  longitude:
                    type: number
                  timestamp:
                    type: string
                    format: date-time
    """
    # Get latest tracking for each live procession's confraternity
    from sqlalchemy import func
    
    live_processions = Procession.query.filter_by(is_live=True).all()
    result = []
    for procession in live_processions:
        # Get latest tracking log for this procession's confraternity
        latest_log = TrackingLog.query.filter_by(
            confraternity_id=procession.confraternity_id
        ).order_by(TrackingLog.timestamp.desc()).first()
        
        if latest_log:
            tracking_data = latest_log.to_dict()
            tracking_data['confraternity_id'] = procession.confraternity_id
            tracking_data['day'] = procession.day
            result.append(tracking_data)
    
    return jsonify(result)


# ============================================================================
# TrackingLog Endpoints (Unified GPS tracking)
# ============================================================================

CAPOFILA_SECRET = os.environ.get('CAPOFILA_SECRET', 'capofila123')


@api_bp.route('/tracking/log', methods=['POST'])
def log_tracking_position():
    """Log a new GPS position for a confraternity
    ---
    tags:
      - Tracking
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - confraternity_id
              - lat
              - lng
              - secret
            properties:
              confraternity_id:
                type: string
                format: uuid
              lat:
                type: number
                format: float
                minimum: -90
                maximum: 90
              lng:
                type: number
                format: float
                minimum: -180
                maximum: 180
              secret:
                type: string
                description: Capofila device authentication secret
    responses:
      200:
        description: Position logged successfully
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  $ref: '#/components/schemas/TrackingPosition'
                error:
                  type: string
                  nullable: true
      400:
        description: Invalid request data
      401:
        description: Unauthorized - invalid secret
      404:
        description: Confraternity not found
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'data': None, 'error': 'No JSON data provided'}), 400
    
    # Validate required fields
    required_fields = ['confraternity_id', 'lat', 'lng']
    for field in required_fields:
        if field not in data:
            return jsonify({'data': None, 'error': f'Missing required field: {field}'}), 400
    
    confraternity_id = data['confraternity_id']
    latitude = data['lat']
    longitude = data['lng']
    secret = data.get('secret')
    
    # Validate confraternity exists
    confraternity = Confraternity.query.get(confraternity_id)
    if not confraternity:
        return jsonify({'data': None, 'error': 'Confraternity not found'}), 404

    # Validate secret (supports both confraternity-specific secret and system default)
    expected_secret = confraternity.capofila_secret or CAPOFILA_SECRET
    if secret != expected_secret and secret != CAPOFILA_SECRET:
        return jsonify({'data': None, 'error': 'Unauthorized - invalid secret'}), 401
    
    # Validate coordinates
    if not (-90 <= latitude <= 90 and -180 <= longitude <= 180):
        return jsonify({'data': None, 'error': 'Invalid coordinates'}), 400
    
    # Create new log entry
    log = TrackingLog(
        confraternity_id=confraternity_id,
        latitude=latitude,
        longitude=longitude,
    )
    db.session.add(log)
    db.session.commit()
    
    return jsonify({'data': log.to_dict(), 'error': None}), 200


@api_bp.route('/tracking/live', methods=['GET'])
def get_live_tracking():
    """Get latest position for each confraternity
    ---
    tags:
      - Tracking
    responses:
      200:
        description: Latest tracking positions for all confraternities
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/TrackingPosition'
                error:
                  type: string
                  nullable: true
    """
    from sqlalchemy import func
    
    # Subquery to get the max timestamp for each confraternity
    subquery = db.session.query(
        TrackingLog.confraternity_id,
        func.max(TrackingLog.timestamp).label('max_timestamp')
    ).group_by(TrackingLog.confraternity_id).subquery()
    
    # Join with the main table to get full records
    latest_logs = db.session.query(TrackingLog).join(
        subquery,
        db.and_(
            TrackingLog.confraternity_id == subquery.c.confraternity_id,
            TrackingLog.timestamp == subquery.c.max_timestamp
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


@api_bp.route('/tracking/history/<confraternity_id>', methods=['GET'])
def get_tracking_history(confraternity_id: str):
    """Get GPS tracking history for a specific confraternity to render map trail
    ---
    tags:
      - Tracking
    parameters:
      - in: path
        name: confraternity_id
        schema:
          type: string
          format: uuid
        required: true
        description: Unique identifier of the confraternity
      - in: query
        name: limit
        schema:
          type: integer
          default: 100
        description: Maximum number of recent positions to return
    responses:
      200:
        description: List of historical GPS positions in chronological order
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/TrackingPosition'
                error:
                  type: string
                  nullable: true
      404:
        description: Confraternity not found
    """
    confraternity = Confraternity.query.get(confraternity_id)
    if not confraternity:
        return jsonify({'data': None, 'error': 'Confraternity not found'}), 404

    try:
        limit = min(int(request.args.get('limit', 100)), 500)
    except (ValueError, TypeError):
        limit = 100

    # Fetch last N logs ordered chronologically (oldest first for polyline drawing)
    recent_logs = (
        TrackingLog.query.filter_by(confraternity_id=confraternity_id)
        .order_by(TrackingLog.timestamp.desc())
        .limit(limit)
        .all()
    )
    # Reverse to have chronological order (from start to current point)
    recent_logs.reverse()

    result = [log.to_dict() for log in recent_logs]
    return jsonify({'data': result, 'error': None}), 200


@api_bp.route('/stats', methods=['GET'])
def get_server_stats():
    """Get summary statistics of the system
    ---
    tags:
      - Health
    responses:
      200:
        description: System summary metrics
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: object
                  properties:
                    confraternities_count:
                      type: integer
                    processions_count:
                      type: integer
                    live_processions_count:
                      type: integer
                    tracking_logs_count:
                      type: integer
                error:
                  type: string
                  nullable: true
    """
    confraternities_count = Confraternity.query.count()
    processions_count = Procession.query.count()
    live_processions_count = Procession.query.filter_by(is_live=True).count()
    tracking_logs_count = TrackingLog.query.count()

    return jsonify({
        'data': {
            'confraternities_count': confraternities_count,
            'processions_count': processions_count,
            'live_processions_count': live_processions_count,
            'tracking_logs_count': tracking_logs_count,
        },
        'error': None,
    }), 200


