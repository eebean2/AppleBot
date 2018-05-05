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
            
            // MARK:- Ping
            
            if msg.content.starts(with: "\(indicator)ping") {
                msg.reply(with: "Pong!")
            }
            
            // MARK:- Test Method
            
            if msg.content.starts(with: "\(indicator)test") {
                if !Parser.creatorCheck(ID: Parser.getUserID(msg: msg)) {
                    unauthorizedReply(msg: msg)
                    return
                }
// TEST METHODS HERE
                
                let parser = Parser()
                parser.parse(msg: msg)
                
                print(parser.command ?? "No Command Found")
                print(parser.against ?? "No User Found")
                print(parser.reason ?? "No Reason Found")
                print(parser.remainder ?? "No Remainder Found")
                
                msg.reply(with: "Test Complete! Please check Xcode logs!")
            }
            
            // MARK:- Shutdown
            
            if msg.content.starts(with: "\(indicator)shutdown") {
                let check = Parser.creatorCheck(ID: Parser.getUserID(msg: msg))
                if check {
                    msg.reply(with: "Thank you for using AppleBot!")
                    bot.disconnect()
                    exit(EXIT_SUCCESS)
                } else {
                    msg.reply(with: "Sorry, I can not do that for you.")
                }
            }
            
            // MARK:- Limit Commands
            
            if msg.content.starts(with: "\(indicator)limitCommand:") {
                
                let parser = Parser()
                parser.parse(msg: msg)
                
                
            }
            
            // MARK:- Uptime
            
            if msg.content.starts(with: "\(indicator)uptime") {
                let perms = commandPerms[Parser.getGuildID(msg: msg)]
                if Parser.permissionCheck(perms: perms!, command:
                    "uptime", msg: msg) {
                    msg.reply(with: "I have been awake for.... \(bot.uptime ?? 0) seconds")
                } else {
                    unauthorizedReply(msg: msg)
                }
            }
            
            
        }
    }
    
    // MARK:- Helper Functions
    
    func setCommandPerm(guild: UInt64, command: Command, perm: [UInt64], msg: Message) {
        if commandPerms.keys.contains(guild) {
            var perms = commandPerms[guild]!
            perms.append([command.string: perm])
            commandPerms[guild] = perms
        } else {
            commandPerms[guild] = [[command.string: perm]]
        }
    }
    
    func updateCommandPerm(guild: UInt64, command: Command, perm: [UInt64], msg: Message) {
        if !commandPerms.keys.contains(guild) {
            commandPerms[guild] = [[command.string: perm]]
            msg.reply(with: "Permission settings for the command \(indicator)\(command.string) have been updated!")
        } else {
            let perms = commandPerms[guild]!
            var v = perm
            for i in perms {
                for p in i {
                    if p.key == command.string {
                        v.append(contentsOf: p.value)
                        v = Array(Set(v))
                        msg.reply(with: "Permission settings for the command \(indicator)\(command.string) have been updated!")
                    }
                }
            }
        }
    }
    
    func unauthorizedReply(msg: Message) {
        msg.reply(with: "I am sorry, you do not have permission to do that.")
    }
}
