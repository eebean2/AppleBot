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
    case emptyString
    case missingReason
    case missingTime
    
    var localizedDescription: String {
        switch self {
        case .missingCommand:
            return "Command Missing, recommended not to return an error."
        case .missingModifier:
            return "Modifier Missing, more information required."
        case .emptyString:
            return "A possible unknown error has occured."
        case .missingReason:
            return "A reason is required for this infraction"
        case .missingTime:
            return "A time must be specified in the duration of `000s`, `000m`, or `000d`"
        }
    }
}

class Parser {
    
    var command: Command?
    var modifier: String?
    var against: User?
    var againstID: UInt64?
    var accusor: User?
    var reason: String?
    var remainder: String?
    var remainderSeporated: [String]?
    
    // MARK: -Parse
    
    func parse(msg: Message, hasModifier: Bool, completion: (_ parser: Parser, _ error: ParserError?) -> Void) {
        let comp = seporate(msg: msg)
        guard !comp.isEmpty else {
            completion(self, ParserError.emptyString)
            return
        }
        if let command = Command(rawValue: comp.first!.dropFirst().lowercased()) {
            self.command = command
        } else {
            completion(self, ParserError.missingCommand)
            return
        }
        if hasModifier && comp.count > 1 {
            if !comp[1].starts(with: "<") {
                modifier = comp[1].lowercased()
                if comp.count > 2 && comp[2].starts(with: "<") {
                    against = msg.mentions.first
                } else if comp.count > 2 && UInt64(comp[2]) != nil {
                    againstID = UInt64(comp[2])
                }
            } else {
                completion(self, ParserError.missingModifier)
                return
            }
        } else if comp.count > 1 && comp[1].starts(with: "<") {
            against = msg.mentions.first
        } else if comp.count > 1 && UInt64(comp[1]) != nil {
            againstID = UInt64(comp[1])
        }
        if against != nil {
            if hasModifier && comp.count > 3 {
                reason = comp.dropFirst(3).joined(separator: " ")
                
                remainderSeporated = comp.dropFirst(3).array
            } else if !hasModifier && comp.count > 1 {
                reason = comp.dropFirst(2).joined(separator: " ")
                remainderSeporated = comp.dropFirst(2).array
            }
        } else {
            if hasModifier && comp.count > 2 {
                remainder = comp.dropFirst(2).joined(separator: " ")
                remainderSeporated = comp.dropFirst(2).array
            } else if !hasModifier && comp.count > 1 {
                remainder = comp.dropFirst().joined(separator: " ")
                remainderSeporated = comp.dropFirst().array
            }
        }
        accusor = msg.author
        completion(self, nil)
    }
    
   
    
    // MARK: -Parse Helpers
    
    private func seporate(msg: Message) -> [String] {
        return msg.content.components(separatedBy: " ")
    }
    
    func getPreferances() -> NSDictionary {
        var pref = [NSString: Any]()
        pref["commandperms"] = commandPerms as [NSNumber: [NSString: [NSNumber]]]
        pref["indicator"] = indicator
        pref["botchannel"] = botChannel
        pref["status"] = status
        pref["roles"] = assignableRoles
        pref["giveaway"] = Giveaway.manager.saveGiveaway()
        return pref as NSDictionary
    }
    
    func parsePreferances(from dict: NSDictionary) {
        commandPerms = dict["commandperms"] as! [UInt64: [String: [UInt64]]]
        indicator = dict["indicator"] as! [UInt64: String]
        botChannel = dict["botchannel"] as! [UInt64: UInt64]
        status = dict["status"] as! String
        let r = dict["roles"] as? [UInt64: [String: UInt64]]
        if r != nil {
            assignableRoles = r!
        }
        if let giveaway = dict["giveaway"] as? NSDictionary {
            Giveaway.manager.giveaway(from: giveaway)
        }
    }
    
    // MARK: -Static Parsers
    
    static func serverCheck(msg: Message) -> Bool {
        return approvedServers.contains(Parser.getGuildID(msg: msg))
    }
    
    static func creatorCheck(msg: Message) -> Bool {
        return creator == Parser.getUserID(msg: msg)
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
    
    static func permissionCheck(perms: [String: [UInt64]], command: String, msg: Message) -> Bool {
        var id = [UInt64]()
        let uroles = Parser.getRoles(msg: msg)
        var urid = [UInt64]()
        for r in uroles! {
            urid.append(r.id.rawValue)
        }
        if !perms.keys.contains(command) {
            return true
        }
        for p in perms {
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
        error("Unknown Permission Failure", inReplyTo: msg)
        print("Unknown Permission Failure at \(#function) for guild \(Parser.getGuildID(msg: msg)). Returning False.")
        return false
    }
    
    static func getCommand(msg: Message) -> String? {
        var i = indicator[Parser.getGuildID(msg: msg)]?.first
        if i == nil {
            i = "!".first
        }
        if msg.content.components(separatedBy: " ").first?.first == i {
            let command = msg.content.components(separatedBy: " ").first!.dropFirst().lowercased()
            print(command)
            if creatorcommands.contains(command) {
                if creatorCheck(msg: msg) {
                    return command
                } else {
                    return nil
                }
            } else {
                if commandPerms[Parser.getGuildID(msg: msg)] != nil {
                    if permissionCheck(perms: commandPerms[Parser.getGuildID(msg: msg)]!, command: command, msg: msg) {
                        return command
                    } else {
                        return nil
                    }
                } else {
                    return command
                }
            }
        } else {
            return nil
        }
    }
}
