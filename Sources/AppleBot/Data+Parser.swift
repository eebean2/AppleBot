//
//  Data+Parser.swift
//  AppleBot
//
//  Created by Erik Bean on 5/3/18.
//

import Sword

class Parser {
    static func serverCheck(ID: UInt64) -> Bool {
        return approvedServers.contains(ID)
    }
    
    static func creatorCheck(ID: UInt64) -> Bool {
        return creator == ID
    }
    
    static func getRole(msg: Message) -> [Role]? {
        print("\n    ROLES\n")
        print(msg.member?.roles)
        return msg.member?.roles
    }
    
    static func getGuildID(msg: Message) -> UInt64 {
        return msg.member?.guild?.id.rawValue ?? 000000000000000000
    }
    
    static func getUserID(msg: Message) -> UInt64 {
        return msg.author?.id.rawValue ?? 000000000000000000
    }
}
