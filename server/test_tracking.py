#!/usr/bin/env python3
"""
Test script for the tracking API endpoints.

This script simulates:
1. POST request to update a position
2. GET request to verify it was saved

Usage: python test_tracking.py
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:5000/api"
CAPOFILA_SECRET = "capofila123"


def get_first_confraternity():
    """Fetch the first confraternity ID from the database."""
    response = requests.get(f"{BASE_URL}/confraternities")
    if response.status_code == 200:
        confraternities = response.json()
        if confraternities:
            return confraternities[0]
    return None


def test_post_tracking_update(confraternity_id, lat, lng):
    """Test POST /api/tracking/log endpoint."""
    print(f"\n📍 Testing POST /api/tracking/log...")
    print(f"   Confraternity ID: {confraternity_id}")
    print(f"   Coordinates: ({lat}, {lng})")
    
    payload = {
        "confraternity_id": confraternity_id,
        "lat": lat,
        "lng": lng,
        "secret": CAPOFILA_SECRET
    }
    
    response = requests.post(
        f"{BASE_URL}/tracking/log",
        json=payload,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"   Status Code: {response.status_code}")
    print(f"   Response: {json.dumps(response.json(), indent=4)}")
    
    return response.status_code == 200


def test_post_tracking_invalid_secret(confraternity_id):
    """Test POST with invalid secret."""
    print(f"\n🔒 Testing POST with invalid secret...")
    
    payload = {
        "confraternity_id": confraternity_id,
        "lat": 40.6263,
        "lng": 14.3758,
        "secret": "wrong_secret"
    }
    
    response = requests.post(
        f"{BASE_URL}/tracking/log",
        json=payload,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"   Status Code: {response.status_code}")
    print(f"   Response: {json.dumps(response.json(), indent=4)}")
    
    return response.status_code == 401


def test_get_live_tracking():
    """Test GET /api/tracking/live endpoint."""
    print(f"\n📡 Testing GET /api/tracking/live...")
    
    response = requests.get(f"{BASE_URL}/tracking/live")
    
    print(f"   Status Code: {response.status_code}")
    data = response.json()
    print(f"   Response: {json.dumps(data, indent=4)}")
    
    return response.status_code == 200 and data.get('error') is None


def test_post_multiple_updates(confraternity_id):
    """Test multiple position updates to verify latest is returned."""
    print(f"\n🔄 Testing multiple position updates...")
    
    # Simulate procession movement (Sorrento area coordinates)
    positions = [
        (40.6263, 14.3750),  # Start at Chiesa del Rosario
        (40.6270, 14.3755),  # Move along Corso Italia
        (40.6280, 14.3760),  # Approaching Piazza Tasso
    ]
    
    for i, (lat, lng) in enumerate(positions, 1):
        payload = {
            "confraternity_id": confraternity_id,
            "lat": lat,
            "lng": lng,
            "secret": CAPOFILA_SECRET
        }
        
        response = requests.post(
            f"{BASE_URL}/tracking/log",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print(f"   ✅ Position {i} logged: ({lat}, {lng})")
        else:
            print(f"   ❌ Position {i} failed: {response.json()}")
            return False
    
    return True


def run_tests():
    """Run all tracking API tests."""
    print("=" * 60)
    print("🔧 TRACKING API TEST SUITE")
    print(f"   Base URL: {BASE_URL}")
    print(f"   Time: {datetime.now().isoformat()}")
    print("=" * 60)
    
    # Get a confraternity to test with
    confraternity = get_first_confraternity()
    if not confraternity:
        print("❌ ERROR: Could not fetch confraternities. Is the server running?")
        print("   Run: source venv/bin/activate && python run.py")
        return False
    
    print(f"\n📌 Using confraternity: {confraternity['name']}")
    print(f"   ID: {confraternity['id']}")
    
    confraternity_id = confraternity['id']
    
    # Run tests
    results = []
    
    # Test 1: Invalid secret
    results.append(("Invalid Secret Auth", test_post_tracking_invalid_secret(confraternity_id)))
    
    # Test 2: Valid POST
    results.append(("POST Tracking Update", test_post_tracking_update(
        confraternity_id, 
        40.6263,  # Sorrento latitude
        14.3758   # Sorrento longitude
    )))
    
    # Test 3: Multiple updates
    results.append(("Multiple Position Updates", test_post_multiple_updates(confraternity_id)))
    
    # Test 4: GET live tracking (should show latest position)
    results.append(("GET Live Tracking", test_get_live_tracking()))
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 TEST RESULTS SUMMARY")
    print("=" * 60)
    
    all_passed = True
    for name, passed in results:
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"   {status}: {name}")
        if not passed:
            all_passed = False
    
    print("\n" + "=" * 60)
    if all_passed:
        print("🎉 ALL TESTS PASSED!")
    else:
        print("⚠️  SOME TESTS FAILED")
    print("=" * 60)
    
    return all_passed


if __name__ == "__main__":
    try:
        run_tests()
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Could not connect to server.")
        print("   Make sure the Flask server is running:")
        print("   $ cd server && source venv/bin/activate && python run.py")
