//
//  StatsScreen.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker J. Harmon on 12/2/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct StatsView: View{
    @EnvironmentObject var navigator: MyNavigator
    @EnvironmentObject var vm: HikingViewModel
    @State private var stats: [HikingData] = []
    
    var body: some View{
        VStack{
            Text("Stats").font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.darkOlive)
                .padding()
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
            
            List {
                ForEach(stats, id: \.id) { stat in
                    VStack(alignment: .leading) {
                        Text("Date: \(stat.date.formatted(.dateTime.month().day().year().hour().minute()))")
                        Text("Steps: \(stat.steps)")
                        Text("Distance: \(stat.distance, specifier: "%.2f") Meters")
                        Text("Time: \(stat.time, specifier: "%.2f")")
                        Text("Elevation Up: \(stat.positiveAltitudeChange, specifier: "%.2f") Meters")
                        Text("Elevation Down: \(stat.negativeAltitudeChange, specifier: "%.2f") Meters")
                        Text("Net Elevation: \(stat.netAltitudeChange, specifier: "%.2f") Meters")
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
            }
            
            Button("Back"){
                navigator.navBack()
            }.buttonStyle(BorderedButtonStyle()).padding()
            
        }.onAppear(){
            Task{
                await getStats()
            }
        }
    }
    
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
}

#Preview{
    StatsView()
}
