//
//  Data+Parser.swift
//  AppleBot
//
//  Created by Erik Bean on 5/3/18.
//

import Sword

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
    
    // MARK: -Parse Helpers
    
    private func seporate(msg: Message) -> [String] {
        return msg.content.components(separatedBy: " ")
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
