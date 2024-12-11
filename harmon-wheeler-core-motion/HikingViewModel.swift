//
//  HikingViewModel.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker Harmon on 12/2/24.
//
// This is where all of the backend work will take place

import Foundation
import FirebaseAuth
import FirebaseFirestore

class HikingViewModel: ObservableObject{
    private let hikingManager = HikingManager()
    private let locationManager = LocationManager()
    private let timerManager = TimerManager()
    
    @Published var steps: Int = 0
    @Published var totalTime: TimeInterval = 0
    @Published var distance: Double = 0.0
    @Published var positiveAltitudeChange: Double = 0.0
    @Published var negativeAltitudeChange: Double = 0.0
    @Published var netAltitudeChange: Double = 0.0
    
    init() {
        // Listen for steps updates
        hikingManager.onStepsUpdate = { [weak self] steps in
            DispatchQueue.main.async {
                self?.steps = steps
            }
        }
        
        // Listen for distance updates
        hikingManager.onDistanceUpdate = { [weak self] newDistance in
            DispatchQueue.main.async {
                self?.distance = newDistance
            }
        }
        
        // Listen for timer updates
        timerManager.onUpdate = { [weak self] elapsedTime in
            DispatchQueue.main.async {
                self?.totalTime = elapsedTime
            }
        }
    }

    
    func checkUserAcct(user: String, pwd:String) async -> Bool{
        do {
            try await Auth.auth().signIn(withEmail: user, password: pwd)
            return true
        } catch {
            print("Error \(error.localizedDescription)")
            return false
        }
    }
    
    func setup() {
        locationManager.startUpdating()
        locationManager.$positiveAltitudeChange.assign(to: &$positiveAltitudeChange)
        locationManager.$negativeAltitudeChange.assign(to: &$negativeAltitudeChange)
        locationManager.$netAltitudeChange.assign(to: &$netAltitudeChange)
    }
    
    func startHike() {
        hikingManager.startTracking()
        timerManager.startTimer()
    }
    
    func stopHike() {
        // Stops capture
        hikingManager.stopTracking()
        timerManager.stopTimer()
        locationManager.stopUpdating()
        
        //Uploads the hike to firebase
        uploadHike()
    }
    
    func uploadHike(){
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore()
        let userHikeStats = db.collection("Users").document(userId).collection("Hikes")
        
        let data: [String: Any] = [
            "date": Timestamp(),
            "time": totalTime,
            "steps": steps,
            "distance": distance,
            "positiveAltitudeChange": positiveAltitudeChange,
            "negativeAltitudeChange": negativeAltitudeChange,
            "netAltitudeChange": netAltitudeChange
        ]
        
        userHikeStats.addDocument(data: data)
        
        //reset timer
        timerManager.resetTimer()
    }
    
    
}
