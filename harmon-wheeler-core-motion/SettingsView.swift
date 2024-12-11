//
//  SettingsView.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker Harmon on 12/2/24.
//

import SwiftUI

struct SettingsView: View{
    @EnvironmentObject var navigator: MyNavigator
    @EnvironmentObject var vm: HikingViewModel
    var body: some View{
        VStack{
            Text("Settings").font(.largeTitle)
                .fontWeight(.bold) // Make it bold
                .foregroundColor(.darkOlive)
                .padding()
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
            
            Spacer()
            
            Button("Use Current"){
                navigator.navBack()
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview{
    SettingsView()
}
