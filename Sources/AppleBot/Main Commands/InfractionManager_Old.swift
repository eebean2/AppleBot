//
//  InfractionTable.swift
//  AppleBot
//
//  Created by Erik Bean on 5/8/18.
//

import Sword
import Foundation

// TODO: Finish me please...

@available(*, deprecated)
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
    @available(*, deprecated)
    func new(_ infraction: Infraction, onGuild guild: UInt64) {
        let gs = Snowflake(rawValue: guild)
        switch infraction.type {
        case .ban:
            var id: Snowflake!
            if infraction.offender != nil {
                id = infraction.offender!.id
            } else {
                id = Snowflake(rawValue: infraction.forceban!)
            }
            bot.ban(id, from: gs, for: infraction.reason, with: [:]) { (err) in
                if let err = err {
                    error("Error banning \(infraction.offender?.username ?? String(id.rawValue))", error: err.message, inReplyTo: infraction.msg)
                } else {
                    error("NOTICE: Offence Tracking is not setup. This infraction will not be logged.")
                }
            }
        case .kick:
            bot.kick(infraction.offender!.id, from: gs, for: infraction.reason) { (err) in
                if let err = err {
                    error("Error kicking \(infraction.offender!.username ?? String(infraction.offender!.id.rawValue))", error: err.message, inReplyTo: infraction.msg)
                } else {
                    error("NOTICE: Offence Tracking is not setup. This infraction will not be logged.")
                }
            }
        default: break
        }
        
        
        
//        saveInfractionTable(inf: infraction, guild: guild)
    }
    
    @available(*, deprecated)
    func summary(_ user: UInt64, onGuild guild: UInt64, withMsg msg: Message) {
        
    }
    
    @available(*, deprecated)
    func delete(_ infraction: Infraction, onGuild guild: UInt64) {
        
    }
    
    @available(*, deprecated)
    func delete(_ id: Int, onGuild guild: UInt64) {
        
    }
    
    @available(*, deprecated)
    func edit(_ id: Int, with: Infraction, onGuild guild: UInt64) {
        
    }
    
    @available(*, deprecated)
    func getInfractionTable() -> [String: Any] {
        let it = [String: Any]()
        
        return it
    }
    
    @available(*, deprecated)
    func checkInfractionTables(_ ignoreReturn: Bool = false) {
        
        var guilds = approvedServers; guilds.append(0)
        for guild in guilds {
            StrikeManager.main.fileCheck(guild: guild)
        }
        
        
        // Here we return the function to avoid running deprecated code
        
        if !ignoreReturn {
            return
        }
        
        // The remainder of this is now deprecated but will remain for future referance
        
        for guild in approvedServers {
            var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
            path.append("/AppleBot/Infractions/\(guild).plist")
            let sf = Snowflake(rawValue: guild)
            bot.getGuild(sf, rest: true) { (g, e: RequestError?) in
                if g != nil {
                    if FileManager.default.fileExists(atPath: path) {
                        ABLogger.log(action: "Infraction table found for guild \(g!.name)")
                    } else {
                        ABLogger.log(action: "Infraction table missing for guild \(g!.name), Infraction table will be created after first user infraction")
                    }
                } else {
                    if e != nil {
                        ABLogger.log(action: "Could not get guild name. Error: \(e!.message)")
                    } else {
                        ABLogger.log(action: "Guild not found, no error found attempting to recover infraction data")
                    }
                    if FileManager.default.fileExists(atPath: path) {
                        ABLogger.log(action: "Infraction table found for guild \(guild)")
                    } else {
                        ABLogger.log(action: "Infraction table missing for guild \(guild), Infraction table will be created after first user infraction")
                    }
                }
            }
            
        }
    }
    
    @available(*, deprecated)
    func loadInfractionTable() -> NSDictionary {
        return NSDictionary()
    }
    
    @available(*, deprecated)
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
    
    @available(*, deprecated)
    func infParser(msg: Message, completion: (_ infraction: Infraction?, _ error: Error?) -> Void){
        Parser().parse(msg: msg, hasModifier: false) { (p, e) in
            
            var reason: String?
            var expTime: Date?
            
            if let e = e {
                completion(nil, e)
            } else {
                print("Infraction: \(InfractionType.getType(p.command!)?.string ?? "No Infraction Type Found")")
                print("Offender: \(p.against?.username ?? "Offender Username not found")")
                if p.against == nil {
                    error("Oh No!", error: "You cannot give an infraction to nobody!", inReplyTo: msg)
                    return
                }
                if !p.remainderSeporated!.isEmpty, let remainderSeporated = p.remainderSeporated {
                    let time = remainderSeporated.first
                    if time?.last == "m".first || time?.last == "d".first || time?.last == "s".first {
                        
                        reason = remainderSeporated.dropFirst().joined(separator: " ")
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
    
    @available(*, deprecated)
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
    
    @available(*, deprecated)
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

// Infraction Format for Reading and Writing
//
// -------------------------------------
// | INFN | UInt64 | Infraction Number |
// | OFFN | UInt64 | Offender          |
// | TYPE | String | Infraction Type   |
// | ACCU | UInt64 | Accuser           |
// | OCUR | Date   | Infraction Date   |
// | EXPD | Date   | Experation Date   |
// | REAS | String | Reason            |
// | MESG | UInt64 | Message ID        |
// | GILD | UInt64 | Guild ID          |
// -------------------------------------
//
// OLD FORMAT, see Wookiee 5 Step
@available(*, deprecated)
struct Infraction {
    var id: UInt64
    var reason: String?
    var type: InfractionType
    var offender: User?
    var forceban: UInt64?
    var accuser: User
    var occuredOn: Date
    var expiresOn: Date?
    var msg: Message?
    var guild: UInt64?
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
        d["INFN"] = id
        d["OFFN"] = offender
        d["TYPE"] = type.rawValue
        d["ACCU"] = accuser
        d["OCUR"] = occuredOn
        d["EXPD"] = expiresOn
        d["REAS"] = reason
        if msg != nil {
            d["MESG"] = msg!.id.rawValue
        }
        if msg != nil {
            d["GILD"] = Parser.getGuildID(msg: msg!)
        }
        return d
    }
    
    func stringValue() -> String {
        let dict = dictionary()
        return (dict.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: ";")
    }
    
    mutating func from(_ data: [String: Any]) {
        id = data["id"] as! UInt64
        reason = data["reason"] as? String
        type = InfractionType(rawValue: data["type"] as! String)!
        offender = data["offender"] as? User
        accuser = data["accuser"] as! User
        occuredOn = data["on"] as! Date
        expiresOn = data["expires"] as? Date
    }
}

@available(*, deprecated)
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
