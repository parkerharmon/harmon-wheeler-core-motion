//
//  MainScreen.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker J. Harmon on 12/2/24.
//

import Foundation
import SwiftUI

struct HikingView: View {
    @EnvironmentObject var vm: HikingViewModel
    @EnvironmentObject var navigator: MyNavigator

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            // Title
            Text("Hiking App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.darkOlive)
                .padding()
                .shadow(color: .gray, radius: 2, x: 1, y: 1)

            // Table with border and shadow
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    Text("Distance: \(vm.distance, specifier: "%.2f") meters")
                    Text("Time: \(vm.totalTime, specifier: "%.2f")")
                    Text("Steps Taken: \(vm.steps)")
                    Text("Positive Altitude Change: \(vm.positiveAltitudeChange, specifier: "%.2f") meters")
                    Text("Negative Altitude Change: \(vm.negativeAltitudeChange, specifier: "%.2f") meters")
                    Text("Net Altitude Change: \(vm.netAltitudeChange, specifier: "%.2f") meters")
                }
                .padding()
                .background(Color(.systemGray6)) // Light gray background
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.darkOlive, lineWidth: 2) // Border
                )
                .shadow(color: .gray, radius: 5, x: 2, y: 2) // Shadow
                .padding()
            }

            // Buttons at the bottom with borders
            HStack {
                Button("Start Hike", action: vm.startHike)
                Button("End Hike", action: vm.stopHike)
            }
            .buttonStyle(BorderedButtonStyle())
            .padding()

            HStack {
                Button("Log Out", action: navigator.logOut)
                Button("View Stats") {
                    navigator.navigate(to: .HikingStatsDestination)
                }
            }
            .buttonStyle(BorderedButtonStyle())
            .padding()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            vm.setup()
        }
    }
}

#Preview {
    HikingView()
        .environmentObject(HikingViewModel())
        .environmentObject(MyNavigator())
}
