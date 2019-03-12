//
//  ABCensor.swift
//  AppleBot
//
//  Created by Erik Bean on 7/27/18.
//

import Foundation

class ABCensor {
    
    static let main = ABCensor()
    private init() { }
    internal(set) var isActive: Bool = false
    var list = [String]()
    
    func lockAndLoad() {
        ABLogger.log(action: "NOTICE: ABCensor.main.lockAndLoad() called, loading and arming censorship guns.")
        #if os(macOS)
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        #else
        var path = Bundle.main.executablePath!
        #endif
        path.append("/AppleBot/BannedWords.txt")
        if FileManager.default.fileExists(atPath: path) {
            do {
                list = try String(contentsOf: URL(fileURLWithPath: path)).components(separatedBy: "\n")
                isActive = true
                ABLogger.log(action: "ABCensor is now locked and loaded, let the censorship begin!")
            } catch let err {
                ABLogger.log(action: "NOTICE: ABCensor failed to log censorship guns with error: \(err.localizedDescription)")
                error("Could not activate text censorship! Error: \(err.localizedDescription)")
            }
        }
    }
    
    func check(_ phrase: String) -> Bool {
        if !isActive {
            ABLogger.log(action: "ABCensor.main.wordCheck(_:) called before .lockAndLoad(), no word list to compare to.")
            error("ABCensor is not active, please call ABCensor.main.lockAndLoad()")
            return false
        }
        if list.count == 0 {
            ABLogger.log(action: "ABCensorship gun contains no ammo. Lock and Load pulled an empty list, or contained an error that did not log. Resetting lock and load.")
            error("An error as occured censoring a message, and we can no longer censor further messages.")
            isActive = false
            return false
        }
        if phrase.isEmpty || phrase == "" { return false }
        var passFail = false
        for i in list {
            passFail = phrase.contains(i)
//            passFail =  phrase.range(of: "\\b\(i)\\b", options: .regularExpression) != nil
            if passFail == true {
                return true
            }
        }
        return false
    }
}
