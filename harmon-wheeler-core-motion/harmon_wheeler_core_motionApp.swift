//
//  harmon_wheeler_core_motionApp.swift
//  harmon-wheeler-core-motion
//
//  Created by Alissa Pavano on 12/11/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct hikingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene{
        WindowGroup{
            AppView()
        }
    }
}
