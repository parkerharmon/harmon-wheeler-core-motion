# Welcome to Go Outside - Our Hiking App!

Hi, and welcome to our coding tutorial for our hiking app! In this tutorial we will be going over IOS' Core Motion library and explain what is needed to get coding and replicate our app in an easy manner. Core Motion is used primarily to capture the motion data of your iPhone. This includes the device's accelerometers, gyroscopes, pedometer, magnetometer, and its barometer. In our project we mainly used the pedometer in order to track steps, but the other measurements could always be used for different projects. For our app specifically it tracks steps taken upon hitting start hike and then ends when the user hits end hike. This data, as well as time and altitude changes from Core Location, get added to our Firestore database. The user then can go into their stats screen and view this data for themselves.

## This is the main screen of the app
When hitting start it will start the various status seen in the box at the top:

**![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXe_5fAcrXn5nIvM-89x4Vr3S2-1Fg4SVDBoJrbEAVrRgZb9hrfhB_edoIpMpMr1cw_LbFmKn6M4KdZ2m7WoqAYMfMoxDIN4eqKaIpx-atum-l0TeI6uR6M8-Erv1-FKV_nvlpwAGw?key=40q58-uwBzoKkBthq8INTJl1)**

## This is the stats screen of the app
After hitting end hike, the stats screen will display all of the hiking data captured. This data is stored on Firebase Firestore:

**![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXeKO_8YqPeS6HsgfIDQMRTKuUg3XNDg37VxP40f8BFnJ-rKFE09g00j7P6b_YbIn6ADz1BvYYV4yrRxn8_trGlSPzdXm6z_Kgpf55kX0c-gA85_xT5z81hJfoZuJQt0KPeIGPKqEg?key=40q58-uwBzoKkBthq8INTJl1)**


# Getting Started

For coding this project we will need the following:
* XCode version 16+ on a mac device.
* A project with the following firebase package dependencies: FirebaseFirestore, FirebaseCore, FirebaseAuth

This is pretty much all that is needed as everything else is built into XCode itself or the Swift language. 

# Coding Instructions
The coding portion of this tutorial will mainly cover how the backend of the app works as UI design was not much of a focus on the app and could always be improved or changed depending on user preference. 

## The structure of the backend consists of one main ViewModel that controls much of the underlying functionality. Here is the code of that model:

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

That is quite a lot so let us dive into it and explain the processes. 

## Setting up the managers
In our view model instantiate 3 managers: one for location, one for motion, and one for a timer.

    private let hikingManager = HikingManager() 
    private let locationManager = LocationManager() 
    private let timerManager = TimerManager()

Let's go over each of the managers themselves

### Hiking Manager

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

This manager is responsible for capturing the users distance and total steps taken during their hike. 

We first initialize those values at the top of this class as well as initialize a pedometer from the Core Motion library. 

We have two callbacks for updates sent back to the main ViewModel set up as well.

The bulk of the code lies in the startTracking method. This method upon start will find out the starting time (i.e. when the user hit the "start hike" button) and then begin tracking the users steps and distance data. The if checks for `CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable()` are used to make sure the user has these features enabled for this app. We are using motion data here, so the user will have to accept the terms of motion capture shown in a pop up menu on the app. 

As a coder you will have to edit your app's `info.plist` file and set a message for Motion Capture and Location Capture (which we will get into in the next manager). A picture to find where this is located is shown below: 

**![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXd2cZZPWhcktw-3900jtSOniLutPUs9JbgaeZ2rRNuWSIeyq2FC_hiAvlkLhG8O7buRuhSGu5chIHFm_b03K1ncymU3oLSBQzDMDXf176RPMzLD2MGz-1cJ0IZ8Pam3gLtLtWQW7g?key=40q58-uwBzoKkBthq8INTJl1)**
### Location Manager

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


This manager tracks the users altitude changes within the hike. 

It does use Core Location, which is a library that we are not entirely focusing on for the app, but we figured that with hiking you are constantly going up and down hills/mountains that altitude data is rather valuable for a user to have.

To keep this section brief, we initialize the required variables for altitude capture and then initializes its location manager object as well as asks users for location access permisions (see the picture above about `info.plist` on where to set that).

Then, in the location manager function we simply have to keep trach of our initial altitude and then periodically check again to see if it has changed. If it does we will see if it is positive or negative and then add it to the respective values. We then change the net altitude value and then set a new starting altitude for where we will compare for our next measurement.

### Timer Manager

	import Foundation
    
    class TimerManager {
        private var timer: Timer?
        private var elapsedTime: TimeInterval = 0
        var onUpdate: ((TimeInterval) -> Void)?
        
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
            self.onUpdate?(self.elapsedTime) // Notify the HikingViewModel
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer(){
        self.elapsedTime = 0
    }
}

This is our Timer Manager. It's pretty simple. When hitting the "start hike" button we will run the timer and then send updates back to the ViewModel as time passes. When "end hike" is hit, we stop the clock. This time is what is then sent to Firestore for our stats screen. 

## Continuing with our View Model

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

This code is responsible for setting up listeners that connect with all of the three managers described above. These listeners will capture the data and then have it saved to our published variables for our main View to display to the user. The way these are set up ensure a reactive stream of data that updates in real time within the main View. We also use `[weak self]` to avoid memory leaks which could be a problem you might run into if you do not set up your listeners in this fashion. 

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
In this code, we provide various functions to the UI that will be called when the user hits either "start hike" or "end hike." These functions will then start up the various tracking mechanisms within the managers.

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

This code is responsible for uploading our hikes into the Firestore database to then be viewed in the Stats screen by users. Documentation on how Firestore works will be in the Related Sections. 

## Pulling Down User Stats

    func getStats() async{
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }
        
        let db = Firestore.firestore()
        let userHikes = db.collection("Users").document(userId).collection("Hikes")
        
        do {
            let querySnapshot = try await userHikes.getDocuments()
            
            let fetchedStats = querySnapshot.documents.compactMap { doc -> HikingData? in
                do {
                    let hikeData = try doc.data(as: HikingData.self)
                    return hikeData
                } catch {
                    print("Error parsing document: \(error.localizedDescription)")
                    return nil
                }
            }
        
            DispatchQueue.main.async {
                self.stats = fetchedStats  // Ensure main thread assignment
            }
            
        } catch {
            print("Firestore Error: \(error.localizedDescription)")
        }
    }

This code is responsible for pulling down the user's stats on the Stats screen. Pretty generic code that is modeled from Firestore's documenation

# Further Conclusions
Overall, I hope this gives you, our reader, a better understanding of how the IOS Core Motion Kit operates and functions in Swift. By following the code snippets you should be able to model an app like ours yourself within XCode 

Here is a link to our GitHub for a complete view of our source code: https://github.com/parkerharmon/harmon-wheeler-core-motion





# Related Sections
Helpful links for to documentation:
* FireStore: https://firebase.google.com/docs/firestore/quickstart
* IOS Core Motion: https://developer.apple.com/documentation/coremotion/
