//
//  HikingData.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Parker Harmon on 12/2/24.
//

import FirebaseFirestore

struct HikingData: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    let date: Date
    let distance: Double
    let steps: Int
    let time: Double
    let positiveAltitudeChange: Double
    let negativeAltitudeChange: Double
    let netAltitudeChange: Double
}
