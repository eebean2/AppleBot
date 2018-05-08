//
//  Data+Parser.swift
//  AppleBot
//
//  Created by Erik Bean on 5/3/18.
//

import Sword
import Foundation

enum ParserError: Error {
    case missingCommand
    case missingModifier
}

class Parser {
    
    var command: Command?
    var modifier: String?
    var against: UInt64?
    var reason: String?
    var remainder: String?
    var remainderSeporated: [String]?
    
    // MARK: -Parse
    
    func parse(msg: Message, hasModifier: Bool, completion: (_ success: Bool, _ error: Error?) -> Void) {
        let comp = seporate(msg: msg)
        if comp.first != nil {
            command = Command(rawValue: comp.first!.dropFirst().lowercased())
        } else {
            msg.reply(with: "An unknown error has occurred. Please try again!")
            completion(false, ParserError.missingCommand)
            return
        }
        if hasModifier {
            if comp.count > 1 {
                if comp[1].starts(with: "<") {
                    completion(false, ParserError.missingModifier)
                    return
                } else {
                    modifier = comp[1]
                    if comp.count > 2 {
                        if comp[2].starts(with: "<") {
                            against = msg.mentions.first?.id.rawValue
                        } else if UInt64(comp[2]) != nil {
                            against = UInt64(comp[2])
                        }
                    }
                }
            } else {
                completion(false, ParserError.missingModifier)
                return
            }
        } else {
            if comp.count > 1 {
                if comp[1].starts(with: "<") {
                    against = msg.mentions.first?.id.rawValue
                } else if UInt64(comp[1]) != nil {
                    against = UInt64(comp[1])
                }
            }
        }
        if against == nil {
            if hasModifier {
                if comp.count > 2 {
                    remainder = comp.dropFirst(2).joined(separator: " ")
                    remainderSeporated = comp.dropFirst(2).array
                }
            } else {
                if comp.count > 1 {
                    remainder = comp.dropFirst().joined(separator: " ")
                    remainderSeporated = comp.dropFirst().array
                }
            }
        } else {
            if hasModifier {
                if comp.count > 3 {
                    reason = comp.dropFirst(3).joined(separator: " ")
                    remainderSeporated = comp.dropFirst(3).array
                }
            } else {
                if comp.count > 2 {
                    reason = comp.dropFirst(2).joined(separator: " ")
                    remainderSeporated = comp.dropFirst(2).array
                }
            }
        }
        completion(true, nil)
    }
    
    func saveToDisc(msg: Message?) {
        var e = Embed()
        e.title = "Saving..."
        e.description = "Most commands will not function during this process!"
        e.color = 0xFFFFFF
        if msg != nil {
            msg!.reply(with: e)
        } else {
            bot.send(e, to: Snowflake(rawValue: testChannel))
        }
        isSaving = true
        
        do {
            let perms = commandPerms as [NSNumber: [[NSString: [NSNumber]]]] //as NSDictionary
print("Command Perms:")
print(perms)
            var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
print("Command Path - Pre Append")
print(path)
            path.append("/AppleBot/test.plist")
print("Command Path - Post Append")
print(path)
//            try d.write(to: URL(fileURLWithPath: path))
            if FileManager.default.fileExists(atPath: path) {
                
            } else {
//                let d: Data = try PropertyListSerialization.data(fromPropertyList: perms, format: .xml, options: 0)
//print("Command Data")
//print(d)
                let d = NSKeyedArchiver.archivedData(withRootObject: perms)
                FileManager.default.createFile(atPath: path, contents: d, attributes: nil)
            }
            e.title = "Save complete"
            e.description = "You can now resume bot use"
            if msg != nil {
                msg!.reply(with: e)
            } else {
                bot.send(e, to: Snowflake(rawValue: testChannel))
            }
            isSaving = false
        }
    }
    
    func readData(msg: Message?) {
        var e = EmbedReply.getEmbed(withTitle: "Loading Settings", message: nil, color: .system)
        if msg != nil {
            msg!.reply(with: e)
        } else {
            bot.send(e, to: Snowflake(rawValue: testChannel))
        }
        isSaving = true
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        path.append("/AppleBot/test.plist")
        let plist = FileManager.default.contents(atPath: path)
        if plist != nil {
            let dict = NSKeyedUnarchiver.unarchiveObject(with: plist!) as? [UInt64: [[String: [UInt64]]]]
            if dict != nil {
                commandPerms = dict!
                e.title = "Settings Loaded"
                if msg != nil {
                    msg!.reply(with: e)
                } else {
                    bot.send(e, to: Snowflake(rawValue: testChannel))
                }
            } else {
                e.title = "Error"
                e.description = "No permission data found"
                e.color = ABColor.alert.intColor
                if msg != nil {
                    msg!.reply(with: e)
                } else {
                    bot.send(e, to: Snowflake(rawValue: testChannel))
                }
            }
        } else {
            e.title = "Error"
            e.description = "No permission setting document found, this error needs to be handled better in future bot versions"
            e.color = ABColor.alert.intColor
            if msg != nil {
                msg!.reply(with: e)
            } else {
                bot.send(e, to: Snowflake(rawValue: testChannel))
            }
        }
        isSaving = false
    }
    
    // MARK: -Parse Helpers
    
    private func seporate(msg: Message) -> [String] {
        return msg.content.components(separatedBy: " ")
    }
    
    private func getPreferances() -> NSDictionary {
        var pref = [NSString: Any]()
        pref["commandperms"] = commandPerms as [NSNumber: [[NSString: [NSNumber]]]]
        pref["indicator"] = indicator
        pref["botChannel"] = botChannel
        return pref as NSDictionary
    }
    
    // MARK: -Static Parsers
    
    static func serverCheck(ID: UInt64) -> Bool {
        return approvedServers.contains(ID)
    }
    
    static func creatorCheck(ID: UInt64) -> Bool {
        return creator == ID
    }
    
    static func getRoles(msg: Message) -> [Role]? {
        return msg.member?.roles
    }
    
    static func getGuildID(msg: Message) -> UInt64 {
        return msg.member?.guild?.id.rawValue ?? 000000000000000000
    }
    
    static func getUserID(msg: Message) -> UInt64 {
        return msg.author?.id.rawValue ?? 000000000000000000
    }
    
    static func getMentionedRole(msg: Message) -> UInt64 {
        return msg.mentionedRoles.first?.rawValue ?? 000000000000000000
    }
    
    static func permissionCheck(perms: [[String: [UInt64]]], command: String, msg: Message) -> Bool {
        var id = [UInt64]()
        let uroles = Parser.getRoles(msg: msg)
        var urid = [UInt64]()
        for r in uroles! {
            urid.append(r.id.rawValue)
        }
        for i in perms {
            for p in i {
                if p.key == command {
                    id = p.value
                    
                    let j = urid.filter{id.contains($0)}
                    
                    if !j.isEmpty {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        print("Unknown Permission Failure at \(#function) for guild \(Parser.getGuildID(msg: msg)). Returning False.")
        return false
    }
}
