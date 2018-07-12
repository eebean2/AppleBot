//
//  ABTimer.swift
//  AppleBot
//
//  Created by Erik Bean on 7/10/18.
//

import Foundation

class ABTimer {
    private var timer: DispatchSourceTimer?
    
    /// Creates a timer,
    init(fire: Date, interval: TimeInterval, repeats: Bool, block: @escaping (ABTimer) -> Void) {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        let i: UInt64 = UInt64(fire.timeIntervalSince(Date()) * 1e+9)
        if repeats {
            timer!.schedule(deadline: DispatchTime(uptimeNanoseconds: i), repeating: interval)
        } else {
            timer!.schedule(deadline: DispatchTime(uptimeNanoseconds: i))
        }
        timer!.setEventHandler { [weak self] in
            block(self!)
        }
        if fire >= Date() {
            start()
        }
    }
    
    func start() {
        timer?.resume()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        self.stop()
    }
}
