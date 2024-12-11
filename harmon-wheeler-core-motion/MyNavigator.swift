//
//  MyNavigator.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker Harmon on 12/2/24.
//

import SwiftUI

//Add new screens to this enum
enum Destination {
    case HikingDestination
    case NewAccountDestination
    case HikingStatsDestination
    case LoginDestination
    case SettingsDestination
}

class MyNavigator: ObservableObject{
    @Published var navPath: NavigationPath = NavigationPath()
    
    //navigate forward
    func navigate(to d: Destination){
        navPath.append(d)
    }
    
    //navigate back
    func navBack(){
        navPath.removeLast()
    }
    
    //empty the stack to go back to login
    func logOut(){
        while navPath.count > 0{
            navPath.removeLast()
        }
    }
    
}
