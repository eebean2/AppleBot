//
//  Logger.swift
//  AppleBot
//
//  Created by Erik Bean on 7/7/18.
//

import Foundation

class ABLogger {
    
    private init() { }
    static let logger = ABLogger()
    private var timer: ABTimer!
    
    static func log(username: String, guild: String, command: String) {
        ABLogger.logger.logToFile("User: \(username) | Guild: \(guild) | Command: \(command.string)")
    }
    
    static func log(action: String) {
        ABLogger.logger.logToFile(action)
    }
    
    func cleanupLogs() {
        ABLogger.log(action: "Log cleanup requested || This will be ran in the background and no errors will be logged outside of this log. This means there will be no UI errors, Xcode errors, and so on.")
        let documentsURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("/AppleBot/Logs")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL!, includingPropertiesForKeys: nil)
            var dates = [String]()
            for file in fileURLs {
                let i = file.absoluteString.components(separatedBy: "/")
                let j = i.last?.components(separatedBy: ".")
                if j?.first == "com" {
                    dates.append(j![2])
                }
            }
            var datecomp = DateComponents()
            datecomp.day = -14
            let date = Calendar.current.date(byAdding: datecomp, to: Date())
            let df = DateFormatter()
            df.dateFormat = "YYYY-MM-DD"
            let ds = df.string(from: date!)
            for date in dates {
                if date < ds {
                    ABLogger.log(action: "Attempting to delete log com.AppleBot.\(date).txt")
                    do {
                        let url = documentsURL?.appendingPathComponent("/com.AppleBot.\(date).txt")
                        try FileManager.default.removeItem(at: url!)
                    } catch let error {
                        ABLogger.log(action: "NOTICE: Failed to delete log com.AppleBot.\(date).txt | ERROR: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            ABLogger.log(action: "Error while enumerating files \(documentsURL?.path ?? "{ PATH ERROR }"): \(error.localizedDescription)")
        }
    }
    
    func setupCleanupTimer() {
        timer = ABTimer(timeInterval: 86400, repeats: true) { _ in
            self.cleanupLogs()
        }
    }
    
    private func logToFile(_ string: String) {
        let string = "\(Date())| \(string)"
        #if os(macOS)
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        #else
        var path = Bundle.main.executablePath!
        #endif
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-DD"
        var file = path; file.append("/AppleBot/Logs/com.AppleBot.\(df.string(from: Date())).txt")
        if FileManager.default.fileExists(atPath: file) {
            if let fileHandle = FileHandle(forWritingAtPath: file) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                let data = string.appending("\n").data(using: .utf8)
                fileHandle.write(data!)
            } else {
                do {
                    let data = string.appending("\n").data(using: .utf8)
                    try data?.write(to: URL(fileURLWithPath: path), options: .atomic)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            var dir = path; dir.append("/AppleBot/Logs")
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: dir, isDirectory: &isDir) {
                if isDir.boolValue {
                    let data = string.appending("\n").data(using: .utf8)
                    if !FileManager.default.createFile(atPath: file, contents: data, attributes: nil) {
                        print("Failed to create file! upper failure")
                        error("Logging Error", error: "Failed to create file! Upper Failure")
                    } else {
                        print("Log File Created!")
                    }
                } else {
                    do {
                        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                        let data = string.appending("\n").data(using: .utf8)
                        if !FileManager.default.createFile(atPath: file, contents: data, attributes: nil) {
                            print("Failed to create file! mid failure")
                            error("Logging Error", error: "Failed to create file! Mid Failure")
                        } else {
                            print("Log File Created!")
                        }
                    } catch let err {
                        error("Logging Error", error: err.localizedDescription)
                    }
                }
            } else {
                do {
                    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                    let data = string.appending("\n").data(using: .utf8)
                    if !FileManager.default.createFile(atPath: file, contents: data, attributes: nil) {
                        print("Failed to create file! lower failure")
                        error("Logging Error", error: "Failed to create file! Lower Failure")
                    } else {
                        print("Log File Created!")
                    }
                } catch let err {
                    error("Logging Error", error: err.localizedDescription)
                }
            }
        }
    }
}
