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
    
    var string: String { return self.rawValue }
    
    static func getType(_ from: Command) -> InfractionType? {
        switch from {
        case .tempmute:
            return InfractionType.tempmute
        default:
            return nil
        }
    }
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
        
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        path.append("/AppleBot/\(guild).plist")
        if FileManager.default.fileExists(atPath: path) {
            if let plist = FileManager.default.contents(atPath: path) {
                if let dict = NSKeyedUnarchiver.unarchiveObject(with: plist) {
                    _ = dict as! NSDictionary
                    
                }
            }
        } else {
            print("No File Found at \(path)")
            print(inf.dictionary())
        }
    }
    
    func infParser(msg: Message, completion: (_ infraction: Infraction?, _ error: Error?) -> Void){
        Parser().parse(msg: msg, hasModifier: false) { (p, e) in
            if let e = e {
                completion(nil, e)
            } else {
                print("Infraction: \(InfractionType.getType(p.command!)?.string ?? "No Infraction Type Found")")
                print("Offender: \(p.against?.username ?? "Offender Username not found")")
                if !p.remainderSeporated!.isEmpty, let remainderSeporated = p.remainderSeporated {
                    let time = remainderSeporated.first
                    if time?.last == "m".first || time?.last == "d".first || time?.last == "s".first {
                        print("Reason: \(remainderSeporated.dropFirst().joined(separator: " "))")
                        print("Infraction Time: \(time!)")
                    } else {
                        completion(nil, ParserError.missingTime)
                    }
                } else {
                    completion(nil, ParserError.missingReason)
                }
                completion(nil,nil)
            }
        }
    }
    
    private func mutedExist(msg: Message, completion: @escaping (Bool, RequestError?) -> Void) {
        msg.member?.guild?.getRoles(then: { (roles, requestError) in
            if let err = requestError {
                completion(false, err)
            } else if let roles = roles {
                for role in roles {
                    if role.name == "Muted" {
                        completion(true, nil)
                    }
                }
            }
            completion(false, nil)
        })
    }
    
    private func createMuted(msg: Message) {
        let muted: [String: Any] = [
            "name": "Muted",
            "permissions": 0,
            "color": 0x808080,
            "hoist": false,
            "mentionable": false
        ]
//        msg.member?.guild?.createRole(with: muted, then: { (role, error) in
//            // code here
//        })
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
    
    func dictionary() -> [String: Any] {
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

enum InfractionPermissions {
    case kick
    case ban
    case mute
    
    var permission: Permission {
        switch self {
        case .kick:
            return Permission.kickMembers
        case .ban:
            return Permission.banMembers
        case .mute:
            return Permission.muteMembers
        }
    }
}
