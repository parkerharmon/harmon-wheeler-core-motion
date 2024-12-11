//
//  AppView.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker Harmon on 12/2/24.
//

import SwiftUI

struct AppView: View{
    @ObservedObject private var navCtrl: MyNavigator = MyNavigator()
    @StateObject var vm: HikingViewModel = HikingViewModel()
    var body: some View{
        NavigationStack(path: $navCtrl.navPath){
            LoginView().environmentObject(vm).environmentObject(navCtrl).navigationDestination(for: Destination.self) {
                d in switch(d){
                    case .HikingDestination: HikingView().environmentObject(vm).navigationBarBackButtonHidden()
                    case .HikingStatsDestination: StatsView().environmentObject(vm).navigationBarBackButtonHidden()
                    case .SettingsDestination: SettingsView().environmentObject(vm).navigationBarBackButtonHidden()
                    case .LoginDestination: LoginView().environmentObject(vm).navigationBarBackButtonHidden()
                    case .NewAccountDestination: NewAccountView().environmentObject(vm).navigationBarBackButtonHidden()
                }
            }
        }.environmentObject(navCtrl)
    }
}
