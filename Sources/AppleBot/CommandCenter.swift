//
//  Command.swift
//  AppleBot
//
//  Created by Erik Bean on 5/3/18.
//

import Sword
import Foundation

class CommandCenter {
    
    func commandCheck(_ msg: Message) {
        if msg.content.first == indicator.first {
            
            if msg.content.starts(with: "\(indicator)ping") {
                msg.reply(with: "Pong!")
            }
            
            if msg.content.starts(with: "\(indicator)test") {
// TEST METHOD HERE
                //Parser.getRole(msg: msg)
                setCommandPerm(guild: 406145333916205076, command: .test, perm: 000000000000000000)
            }
            
            if msg.content.starts(with: "\(indicator)shutdown") {
                let check = Parser.creatorCheck(ID: Parser.getUserID(msg: msg))
                if check {
                    msg.reply(with: "Thank you for using AppleBot!")
                    exit(EXIT_SUCCESS)
                } else {
                    msg.reply(with: "Sorry, I can not do that for you.")
                }
            }
        }
    }
    
    func setCommandPerm(guild: UInt64, command: Command, perm: UInt64) {
        
        print(commandPerms)
        
        if commandPerms.keys.contains(guild) {
            var perms = commandPerms[guild]!
            print(perms)
        }
    }
}
