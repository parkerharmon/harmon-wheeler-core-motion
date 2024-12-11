//
//  LocationManager.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Owen Wheeler on 12/10/24.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var previousAltitude: CLLocationDistance?
    private var initialAltitude: CLLocationDistance?
    
    @Published var positiveAltitudeChange: CLLocationDistance = 0.0
    @Published var negativeAltitudeChange: CLLocationDistance = 0.0
    @Published var netAltitudeChange: CLLocationDistance = 0.0
    
    var distance: Double = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Set begining altitude when the first location update is received
        if initialAltitude == nil {
            initialAltitude = newLocation.altitude
        }
        
        // Track altitude change only if the altitude is available
        if let previousAltitude = previousAltitude {
            let altitudeChange = newLocation.altitude - previousAltitude
            
            // Adding to either positve change or negative depending on the change
            if altitudeChange > 0 {
                positiveAltitudeChange += altitudeChange
            } else if altitudeChange < 0 {
                negativeAltitudeChange += altitudeChange
            }
        }
        
        // Update net altitude change based on initial altitude
        if let initialAltitude = initialAltitude {
            netAltitudeChange = newLocation.altitude - initialAltitude
        }
        
        // Update previous altitude for the next location update
        previousAltitude = newLocation.altitude
    }
}
