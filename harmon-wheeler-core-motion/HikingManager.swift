//
//  HikingManager.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker Harmon on 12/2/24.
//

//import CoreMotion
//
//class HikingManager {
//    private let pedometer = CMPedometer()
//
//    var steps: Int = 0
//    var distance: Double = 0.0
//    var startingTime: Date?
//    var endingTime: Date?
//
//    func startTracking(){
//        startingTime = Date()
//
//        if CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable(){
//            pedometer.startUpdates(from: Date()) {
//                data, error in
//                if let error = error {
//                    print("Error in pedometer capture: \(error.localizedDescription)")
//                    return
//                }
//
//                if let data = data {
//                    self.steps = data.numberOfSteps.intValue
//                    self.distance = data.distance?.doubleValue ?? 0.0
//                    self.endingTime = data.endDate
//                }
//            }
//        }
//    }
//
//    func stopTracking(){
//        pedometer.stopUpdates()
//    }
//}

import CoreMotion

class HikingManager {
    private let pedometer = CMPedometer()
    
    var steps: Int = 0 {
        didSet {
            onStepsUpdate?(steps)
        }
    }
    var distance: Double = 0.0 {
        didSet {
            onDistanceUpdate?(distance)
        }
    }
    
    var startingTime: Date?
    var endingTime: Date?
    
    // Callbacks for updates
    var onStepsUpdate: ((Int) -> Void)?
    var onDistanceUpdate: ((Double) -> Void)?
    
    func startTracking() {
        startingTime = Date()
        
        if CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { data, error in
                if let error = error {
                    print("Error in pedometer capture: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    self.steps = data.numberOfSteps.intValue
                    self.distance = data.distance?.doubleValue ?? 0.0
                    self.endingTime = data.endDate
                }
            }
        }
    }
    
    func stopTracking() {
        pedometer.stopUpdates()
    }
}
