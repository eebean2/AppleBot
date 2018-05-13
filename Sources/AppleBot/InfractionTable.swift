//
//  InfractionTable.swift
//  AppleBot
//
//  Created by Erik Bean on 5/8/18.
//

import Sword
import Foundation

enum InfractionType: String {
    case kick = "Kick"
    case ban = "Ban"
    case tempban = "Temporary Ban"
    case tempmute = "Temporary Mute"
    case mute = "Mute"
    case warning = "Warning"
}

class InfractionManagement {
    func new(_ infraction: Infraction, onGuild guild: UInt64) {
        saveInfractionTable(inf: infraction, guild: guild)
    }
    
    func summary(_ user: UInt64, onGuild guild: UInt64, withMsg msg: Message) {
        
    }
    
    func delete(_ infraction: Infraction, onGuild guild: UInt64) {
        
    }
    
    func delete(_ id: Int, onGuild guild: UInt64) {
        
    }
    
    func edit(_ id: Int, with: Infraction, onGuild guild: UInt64) {
        
    }
    
    func getInfractionTable() -> [String: Any] {
        let it = [String: Any]()
        
        return it
    }
    
    func checkInfractionTables() {
        for guild in approvedServers {
            var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
            path.append("/AppleBot/\(guild).plist")
            let sf = Snowflake(rawValue: guild)
            bot.getGuild(sf, rest: true) { (g, e: RequestError?) in
                if g != nil {
                    if FileManager.default.fileExists(atPath: path) {
                        message("Infraction table found for guild \(g!.name)")
                    } else {
                        error("Infraction table missing for guild \(g!.name)", error: "Infraction table will be created after first user infraction")
                    }
                } else {
                    if e != nil {
                        error("Could not get guild name.", error: e!.message)
                    } else {
                        print("Guild not found, no error found")
                    }
                    if FileManager.default.fileExists(atPath: path) {
                        message("Infraction table found for guild \(guild)")
                    } else {
                        error("Infraction table missing for guild \(guild)", error: "Infraction table will be created after first user infraction")
                    }
                }
            }
            
        }
    }
    
    func loadInfractionTable() -> NSDictionary {
        return NSDictionary()
    }
    
    func saveInfractionTable(inf: Infraction, guild: UInt64) {
        print("New infraction on Guild: \(guild)")
        print("ID: \(inf.id)")
        print("Type: \(inf.type.rawValue)")
        print("Offender: \(inf.offender?.username ?? "Missing Offender")")
        print("Accuser: \(inf.accuser.username ?? "Missing Accuser")")
        print("Reason: \(inf.reason ?? "No Reason Specified")")
    }
}

struct Infraction {
    var id: Int
    var reason: String?
    var type: InfractionType
    var offender: User?
    var forceban: UInt64?
    var accuser: User
    var occuredOn: Date
    var expiresOn: Date?
    var active: Bool {
        if expiresOn != nil {
            if Date() >= expiresOn! {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    func data() -> [String: Any] {
        var d = [String: Any]()
        d["id"] = id
        d["reason"] = reason
        d["type"] = type.rawValue
        d["offender"] = offender
        d["accuser"] = accuser
        d["on"] = occuredOn
        d["expires"] = expiresOn
        return d
    }
    
    mutating func from(_ data: [String: Any]) {
        id = data["id"] as! Int
        reason = data["reason"] as? String
        type = InfractionType(rawValue: data["type"] as! String)!
        offender = data["offender"] as? User
        accuser = data["accuser"] as! User
        occuredOn = data["on"] as! Date
        expiresOn = data["expires"] as? Date
    }
}
