//
//  TimerManager.swift
//  ios-harmon-wheeler-core-motion
//
//  Created by Owen Wheeler on 12/2/24.
//

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
