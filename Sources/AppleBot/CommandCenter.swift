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
// TEST METHODS HERE --------------------------------------------
                
                msg.reply(with: "Server ID: \(Parser.getGuildID(msg: msg))")
                msg.reply(with: commandPerms.description)
                
// END OF TEST METHOD -------------------------------------------
                
                var e = Embed()
                e.color = 000000
                e.description = "**Test Complete!** Please check Xcode's logs!"
                msg.reply(with: e)
            }
            
            // MARK:- Shutdown
            
            if msg.content.starts(with: "\(indicator)shutdown") {
                let check = Parser.creatorCheck(ID: Parser.getUserID(msg: msg))
                if check {
                    var e = Embed()
                    e.color = 00000
                    e.description = "*Thank you for using AppleBot!*"
                    msg.reply(with: e)
                    bot.disconnect()
                    exit(EXIT_SUCCESS)
                } else {
                    msg.reply(with: "Sorry, I can not do that for you.")
                }
            }
            
            // MARK:- Limit Commands
            
            if msg.content.starts(with: "\(indicator)limitCommand") {
                
                let parser = Parser()
                parser.parse(msg: msg, hasModifier: true) { (success, error) in
                    if error != nil {
                        let error = error as! ParserError
                        if error == .missingModifier {
                            missingArg(msg: msg)
                        }
                    } else {
                        if parser.modifier != nil {
                            print(parser.command?.rawValue ?? "Command Error")
                            print(parser.modifier!)
                            print(msg.mentionedRoles)
                            if checkPermExist(command: parser.command!, guild: Parser.getGuildID(msg: msg)) {
                                if !msg.mentionedRoles.isEmpty {
                                    updateCommandPerm(guild: Parser.getGuildID(msg: msg), command: parser.command!, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                                } else {
                                    missingArg(msg: msg)
                                }
                            } else {
                                if !msg.mentionedRoles.isEmpty {
                                    setCommandPerm(guild: Parser.getGuildID(msg: msg), command: parser.command!, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                                } else {
                                    missingArg(msg: msg)
                                }
                            }
                        } else {
                            missingArg(msg: msg)
                        }
                    }
                }
                // !limit [command] to [role]
                
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
    
    func checkPermExist(command: Command, guild: UInt64) -> Bool {
        if commandPerms.keys.contains(guild) {
            let perms = commandPerms[guild]!
            for i in perms {
                for p in i {
                    if p.key == command.string {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func setCommandPerm(guild: UInt64, command: Command, role: [UInt64], msg: Message) {
        if commandPerms.keys.contains(guild) {
            var perms = commandPerms[guild]!
            perms.append([command.string: role])
            commandPerms[guild] = perms
        } else {
            commandPerms[guild] = [[command.string: role]]
        }
        msg.reply(with: "The command \(command.string) has been saved!")
    }
    
    func updateCommandPerm(guild: UInt64, command: Command, role: [UInt64], msg: Message) {
        if !commandPerms.keys.contains(guild) {
            commandPerms[guild] = [[command.string: role]]
        } else {
            let perms = commandPerms[guild]!
            var v = role
            for i in perms {
                for p in i {
                    if p.key == command.string {
                        v.append(contentsOf: p.value)
                        v = Array(Set(v))
                    }
                }
            }
        }
        msg.reply(with: "The command \(command.string) has been updated!")
    }
    
    func unauthorizedReply(msg: Message) {
        msg.reply(with: "I am sorry, you do not have permission to do that.")
    }
    
    func missingArg(msg: Message) {
        msg.reply(with: "Error: This command requires more information!")
    }
}
