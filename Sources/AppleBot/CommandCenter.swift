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
        
        if isSaving {
            msg.reply(with: "**ERROR:** I cannot do that while saving data, please try again when finished.")
            return
        }
        
        let i: Character = indicator[Parser.getGuildID(msg: msg)]?.first ?? "!".first!
        
        if msg.content.first == i {
            
            // MARK:- Add Role
            if msg.content.starts(with: "\(i)addRole") {
                
            }
            
            if msg.content.starts(with: "\(i)rm") {
                Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                    if e != nil {
                        if e == ParserError.missingModifier {
                            error("Missing Command", error: "Try `rma help` for a list of commands", inReplyTo: msg)
                        } else {
                            error("Unknown Parsing Error")
                        }
                    } else {
                        RoleManager().rm(msg: msg, parser: p)
                    }
                }
            }
            
            if msg.content.starts(with: "\(i)rma") {
                Parser().parse(msg: msg, hasModifier: true) { (p, e: ParserError?) in
                    if e != nil {
                        if e == ParserError.missingModifier {
                            error("Missing Command", error: "Try `rma help` for a list of commands", inReplyTo: msg)
                        } else {
                            error("Unknown Parsing Error")
                        }
                    } else {
                        RoleManager().rma(msg: msg, parser: p)
                    }
                }
            }
            
            // MARK:- Ping
            
            if msg.content.starts(with: "\(i)ping") {
                msg.reply(with: "Pong!")
            }
            
            // MARK:- Test Method
            
            if msg.content.starts(with: "\(i)test") {
                if !Parser.creatorCheck(ID: Parser.getUserID(msg: msg)) {
                    unauthorizedReply(msg: msg)
                    return
                }
// TEST METHODS HERE --------------------------------------------
                Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                    if e != nil {
                        error("Parsing Error", error: e!.localizedDescription, inReplyTo: msg)
                    } else {
                        let inf = Infraction(id: 1, reason: p.reason, type: .warning, offender: p.against, forceban: nil, accuser: p.accusor!, occuredOn: Date(), expiresOn: nil)
                        InfractionManagement().new(inf, onGuild: Parser.getGuildID(msg: msg))
                        EmbedReply().reply(to: msg, title: "Test Completed", message: nil, color: .testing)
                    }
                }
                
//                var testResponse = Embed()
//                testResponse.color = 0x00FFFF
//                testResponse.title = "Test Completed:"
////                testResponse.description = """
////                **Error:** \(err?.localizedDescription ?? "No Error")
////                """
//                msg.reply(with: testResponse)
                
// END OF TEST METHOD -------------------------------------------
                
                var e = Embed()
                e.title = "Reminder:"
                e.color = 0x00FFFF
                e.description = "Don't forget to check Xcode's logs!"
                msg.reply(with: e)
            }
            
            // MARK:- Shutdown
            
            if msg.content.starts(with: "\(i)shutdown") {
                let check = Parser.creatorCheck(ID: Parser.getUserID(msg: msg))
                if check {
                    botShutdown(msg: msg)
                } else {
                    EmbedReply().error(on: msg, error: "Sorry, I can not do that for you")
                }
            }
            
            // MARK:- Limit Commands
            
            if msg.content.starts(with: "\(i)limitCommand") {
                Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                    if e != nil {
                        let e = e as! ParserError
                        if e == .missingModifier {
                            missingArg(msg: msg)
                        }
                    } else {
                        if p.modifier != nil {
                            print(p.command?.rawValue ?? "Command Error")
                            print(p.modifier!)
                            print(msg.mentionedRoles)
                            if checkPermExist(command: p.command!, guild: Parser.getGuildID(msg: msg)) {
                                if !msg.mentionedRoles.isEmpty {
                                    updateCommandPerm(guild: Parser.getGuildID(msg: msg), command: p.command!, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                                } else {
                                    missingArg(msg: msg)
                                }
                            } else {
                                if !msg.mentionedRoles.isEmpty {
                                    setCommandPerm(guild: Parser.getGuildID(msg: msg), command: p.command!, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
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
            
            if msg.content.starts(with: "\(i)uptime") {
                let perms = commandPerms[Parser.getGuildID(msg: msg)]
                if Parser.permissionCheck(perms: perms!, command:
                    "uptime", msg: msg) {
                    msg.reply(with: "I have been awake for.... \(bot.uptime ?? 0) seconds")
                } else {
                    unauthorizedReply(msg: msg)
                }
            }
            
            if msg.content.starts(with: "\(i)setStatus") {
                if Parser.creatorCheck(ID: Parser.getUserID(msg: msg)) {
                    Parser().parse(msg: msg, hasModifier: false) { (p, error) in
                        if error != nil {
                            EmbedReply().error(on: msg, error: "Cound not change status: \(error!.localizedDescription)")
                        } else {
                            if p.remainder != nil {
                                bot.editStatus(to: "online", playing: p.remainder!)
                                EmbedReply().reply(to: msg, title: "Status Updated", message: nil, color: .system)
                            } else {
                                EmbedReply().error(on: msg, error: "Cound not change status: No status found")
                            }
                        }
                    }
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
