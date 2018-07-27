//
//  ABTimer.swift
//  AppleBot
//
//  Created by Erik Bean on 7/10/18.
//

import Foundation

class ABTimer {
    
    private var timer: DispatchSourceTimer!
    
    /// Creates a timer
    @discardableResult
    init(timeInterval interval: TimeInterval, repeats: Bool = false, block: ((ABTimer) -> Void)? = nil) {
        timer?.cancel()
        let queue = DispatchQueue(label: "com.applebot.timer", attributes: .concurrent)
        timer = DispatchSource.makeTimerSource(queue: queue)
        if repeats {
            timer.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(100))
        } else {
            timer.schedule(deadline: .now())
        }
        timer.setEventHandler(qos: .background) { [weak self] in
            guard let strongSelf = self else { return }
            block?(strongSelf)
        }
        timer.resume()
    }
    
    func start() {
        timer?.resume()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        timer?.cancel()
        timer = nil
    }
}
