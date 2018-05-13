//
//  CommandCenter.swift
//  AppleBot
//
//  Created by Erik Bean on 5/13/18.
//

import Foundation
import Sword

class CommandCenter {
    
    func commandCheck(_ command: String, msg: Message) {
        if isSaving {
            error("Error", error: "I cannot do that while the bot is saving or writing data, please try again when finished", inReplyTo: msg)
        }
        
        // MARK:- Role Manager Commands
        // MARK: Role Manager
        
        if command == "rm" {
            Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                if e != nil {
                    if e == ParserError.missingModifier {
                        error("Missing Command", error: "Try `rm help` for a list of commands", inReplyTo: msg)
                    } else {
                        error("Unknown Parsing Error")
                    }
                } else {
                    RoleManager().rm(msg: msg, parser: p)
                }
            }
        }
        
        // MARK: Manager Add Role
        
        if command == "rma" {
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
        
        // MARK: Manager Remove Role
        
        if command == "rmr" {
            Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                if e != nil {
                    if e == ParserError.missingModifier {
                        error("Missing Command", error: "Try `rmr help` for a list of commands", inReplyTo: msg)
                    } else {
                        error("Unknown Parsing Error")
                    }
                } else {
                    RoleManager().rmr(msg: msg, parser: p)
                }
            }
        }
        
        // MARK: Add Self
        
        if command == "giverole" || command == "gvr" {
            Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                if e != nil {
                    error("Unknown Parsing Error")
                } else {
                    RoleManager().giverole(msg: msg, parser: p)
                }
            }
        }
        
        // MARK: Remove Self
        
        if command == "removeole" || command == "tkr" {
            Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                if e != nil {
                    error("Unknown Parsing Error")
                } else {
                    RoleManager().removerole(msg: msg, parser: p)
                }
            }
        }
        
        // MARK:- Ping (needs test added)
        
        if command == "ping" {
            msg.reply(with: ":thonk: Pong!")
        }
        
        // MARK:- Test
        
        if command == "test" {
            
        }
        
        // MARK:- Shutdown
        
        if command == "shutdown" {
            if Parser.creatorCheck(ID: Parser.getUserID(msg: msg)) {
                botShutdown(msg: msg)
            } else {
                
            }
        }
        
        // MARK:- WhoAmI
        
        if command == "whoami" {
            let message = """
            **Created By:** eebean2#0001
            **For:** /r/Apple Discord
            **Version:** \(version)
            """
            EmbedReply().reply(to: msg, title: "I Am Apple Bot", message: message, color: .apple)
            
        }
        
        if command == "limitcommand" {
            Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                if e != nil {
                    if e == .missingModifier {
                        error("This command requires more information!", inReplyTo: msg)
                    }
                } else {
                    if p.modifier != nil {
                        if checkPermExist(command: p.command!, guild: Parser.getGuildID(msg: msg)) {
                            if !msg.mentionedRoles.isEmpty {
                                updateCommandPerm(guild: Parser.getGuildID(msg: msg), command: p.command!, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                            } else {
                                error("This command requires more information!", inReplyTo: msg)
                            }
                        } else if !msg.mentionedRoles.isEmpty {
                            setCommandPerm(guild: Parser.getGuildID(msg: msg), command: p.command!, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                        } else {
                            error("This command requires more information!", inReplyTo: msg)
                        }
                    } else {
                        error("This command requires more information!", inReplyTo: msg)
                    }
                }
            }
        }
        
        // MARK:- Uptime
        
        if command == "uptime" {
            EmbedReply().reply(to: msg, title: "I have been awake for...", message: "\(bot.uptime ?? 0) seconds", color: .system)
        }
        
        // MARK:- Update Status
        
        if command == "setstatus" {
            Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                if e != nil {
                    error("Could not chance status", error: e!.localizedDescription, inReplyTo: msg)
                } else {
                    if p.remainder != nil {
                        if p.remainder! == "offline" {
                            bot.editStatus(to: "offline")
                        } else {
                            bot.editStatus(to: "online", playing: p.remainder!)
                        }
                        EmbedReply().reply(to: msg, title: "Status Updated", message: nil, color: .system)
                    } else {
                        error("Could not chance status", error: "No status found", inReplyTo: msg)
                    }
                }
            }
        }
        
        // MARK:- Approved
        
        if command == "approved" {
            if Parser.serverCheck(ID: Parser.getGuildID(msg: msg)) {
                EmbedReply().reply(to: msg, title: "You are approved to use Apple Bot!", message: "Command away!", color: .apple)
            } else {
                error("iTunes has stopped working...", error: "Just kidding, but really... you are not approved to use me here. Sorry!", inReplyTo: msg)
            }
        }
        
        if command == "permcheck" {
            if commandPerms[Parser.getGuildID(msg: msg)] != nil {
                if msg.member?.guild != nil {
                    bot.getRoles(from: msg.member!.guild!.id) { (roles, e) in
                        if e != nil {
                            error("Permission Check Error", error: e!.message, inReplyTo: msg)
                        } else {
                            if roles == nil {
                                error("Permission Check Error", error: "No roles found", inReplyTo: msg)
                                return
                            }
                            var list = String()
                            var rlist = String()
                            for perms in commandPerms[Parser.getGuildID(msg: msg)]! {
                                for perm in perms {
                                    list.append("**\(perm.key):** ")
                                    for id in perm.value {
                                        for role in roles! {
                                            if role.id.rawValue == id {
                                                if rlist != "" {
                                                    rlist.append(", ")
                                                }
                                                rlist.append(role.name)
                                            }
                                        }
                                    }
                                    list.append(rlist)
                                    rlist = ""
                                }
                            }
                            EmbedReply().reply(to: msg, title: "Permission List", message: list, color: .system)
                        }
                    }
                }
            }
        }
        
        // MARK:- Help
        
        if command == "help" {
            if msg.member != nil {
                bot.getDM(for: msg.member!.user.id) { (dm, e) in
                    if e != nil {
                        error("There was an error getting help", error: "Please try again later", inReplyTo: msg)
                    } else {
                        if dm == nil {
                            error("There was an error getting help", error: "Please try again later", inReplyTo: msg)
                        } else {
                            help().getHelp(dm: dm!, msg: msg)
                        }
                    }
                }
            }
        }
        
        // MARK:- New Commands Here
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
}
