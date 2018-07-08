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
        
        bot.getGuild(Snowflake(rawValue: Parser.getGuildID(msg: msg))) { (guild, err) in
            if err == nil && guild != nil {
                ABLogger.log(username: msg.author!.username ?? String(msg.author!.id.rawValue), guild: guild!.name, command: command)
            } else {
                if Parser.getGuildID(msg: msg) == 000000000000000000 {
                    ABLogger.log(username: msg.author!.username ?? String(msg.author!.id.rawValue), guild: "Private DM", command: command)
                } else {
                    ABLogger.log(username: msg.author!.username ?? String(msg.author!.id.rawValue), guild: String(Parser.getGuildID(msg: msg)), command: command)
                }
            }
        }
        
        
        
        if isSaving {
            error("Error", error: "I cannot do that while the bot is saving or writing data, please try again when finished", inReplyTo: msg)
        }
        
        // MARK:- Role Manager Commands
        // MARK:- Role Manager
        
        if command == "rm" {
            Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                if e != nil {
                    if e == ParserError.missingModifier {
                        error("Missing Command", error: "Try `rm help` for a list of commands", inReplyTo: msg)
                    } else {
                        error("Unknown Parsing Error")
                    }
                } else {
                    RoleManager.shared.rm(msg: msg, parser: p)
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
                    RoleManager.shared.rma(msg: msg, parser: p)
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
                    RoleManager.shared.rmr(msg: msg, parser: p)
                }
            }
        }
        
        // MARK: Add Self
        
        if command == "giverole" || command == "gvr" {
            Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                if e != nil {
                    error("Unknown Parsing Error")
                } else {
                    RoleManager.shared.giverole(msg: msg, parser: p)
                }
            }
        }
        
        // MARK: Remove Self
        
        if command == "removerole" || command == "tkr" {
            Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                if e != nil {
                    error("Unknown Parsing Error")
                } else {
                    RoleManager.shared.removerole(msg: msg, parser: p)
                }
            }
        }
        
        // MARK:- Ping (needs test added)
        
        if command == "ping" {
            msg.reply(with: ":thonk: Pong!")
//            ABLogger.log(action: "NOTICE: Using Ping as test command, current test | ABLogger.logger.cleanupLogs() | Please view the remainder of logs till the next startup with caution")
//            ABLogger.logger.cleanupLogs()
        }
        
        // MARK:- Shutdown
        
        if command == "shutdown" {
            ABLogger.log(action: "!!!! Shutdown was attempted !!!!")
            if Parser.creatorCheck(msg: msg) {
                Parser().parse(msg: msg, hasModifier: false) { (p, e) in
                    if e != nil {
                        error("Parser error, attempting non-forced shutdown", inReplyTo: msg)
                        botShutdown(msg: msg)
                    } else {
                        if p.remainder == nil {
                            botShutdown(msg: msg)
                        } else if p.remainder == "forced" {
                            botShutdown(msg: msg, forced: true)
                        } else {
                            error("Unknown shutdown modifier, attempting non-forced shutdown")
                            botShutdown(msg: msg)
                        }
                    }
                }
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
        
        // MARK:- Limit Command
        
        if command == "limitcommand" {
            Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                if e != nil {
                    if e == .missingModifier {
                        error("This command requires more information!", inReplyTo: msg)
                    }
                } else {
                    if p.modifier != nil {
                        if let command = Command(rawValue: p.modifier!) {
                            if checkPermExist(command: command, guild: Parser.getGuildID(msg: msg)) {
                                if !msg.mentionedRoles.isEmpty {
                                    updateCommandPerm(guild: Parser.getGuildID(msg: msg), command: command, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                                    ABLogger.log(action: "Command \(command.string) restrictions updated")
                                } else {
                                    error("This command requires more information!", inReplyTo: msg)
                                }
                            } else if !msg.mentionedRoles.isEmpty {
                                setCommandPerm(guild: Parser.getGuildID(msg: msg), command: command, role: [msg.mentionedRoles.first!.rawValue], msg: msg)
                                ABLogger.log(action: "Command \(command.string) restrictions set")
                            } else {
                                error("This command requires more information!", inReplyTo: msg)
                            }
                        } else {
                            error("This command is not supported yet, please alert the developer to have it added!", inReplyTo: msg)
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
            ABLogger.log(action: "AppleBot Uptime: \(String(describing: bot.uptime))")
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
                            ABLogger.log(action: "Status set to offline")
                        } else {
                            status = p.remainder!
                            bot.editStatus(to: "online", playing: p.remainder!)
                            ABLogger.log(action: "Status set to \(p.remainder!)")
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
            if Parser.serverCheck(msg: msg) {
                EmbedReply().reply(to: msg, title: "You are approved to use Apple Bot!", message: "Command away!", color: .apple)
            } else {
                error("iTunes has stopped working...", error: "Just kidding, but really... you are not approved to use me here. Sorry!", inReplyTo: msg)
                ABLogger.log(action: "!!!! WARNING !!!! Guild \(Parser.getGuildID(msg: msg)) attempted to use AppleBot without validation")
            }
        }
        
        // MARK:- Permission Check
        
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
                            ABLogger.log(action: "Help list sent to \(msg.author!.username ?? String(msg.author!.id.rawValue))")
                        }
                    }
                }
            }
        }
        
        // MARK:- Set Indicator
        
        if command == "setindicator" {
            Parser().parse(msg: msg, hasModifier: false) { (p, err) in
                if let err = err {
                    error("There was an error changing your indicator, please try again", error: err.localizedDescription, inReplyTo: msg)
                } else if let i = p.remainder?.first {
                    indicator[Parser.getUserID(msg: msg)] = String(i)
                    EmbedReply().reply(to: msg, title: "Your bot indicator has been changed", message: "Apple Bot will now respond to commands that start with \(p.remainder!.first!)", color: .apple)
                    ABLogger.log(action: "Indicator for guild \(Parser.getGuildID(msg: msg)) changed to \(p.remainder!.first!))")
                } else {
                    error("This command requires more information!", inReplyTo: msg)
                }
            }
        }
        
        // MARK:- Save Preferances
        
        if command == "saveprefs" {
            forceSave(msg: msg)
        }
        
        // MARK:- Infraction Commands
        // MARK: Tempmute
        
        if command == "tempmute" {
            InfractionManagement().infParser(msg: msg) { (inf, e) in
                if let e = e {
                    error("Infraction Parsing Error", error: e.localizedDescription, inReplyTo: msg)
                } else if let inf = inf {
                    InfractionManagement().new(inf, onGuild: Parser.getGuildID(msg: msg))
                }
            }
            
//            Parser().parse(msg: msg, hasModifier: false) { (p, e: ParserError?) in
//                if e != nil {
//                    error("An unknown error occured", inReplyTo: msg)
//                } else {
//                    let inf = Infraction(id: 1, reason: p.reason, type: .tempmute, offender: p.against, forceban: nil, accuser: p.accusor!, occuredOn: Date(), expiresOn: Date())
//                    InfractionManagement().new(inf, onGuild: Parser.getGuildID(msg: msg))
//                }
//            }
        }
        
        // MARK: New Infraction Command Here
        
        // MARK:- Giveaway Commands
        
        if command == "giveaway" {
            Parser().parse(msg: msg, hasModifier: true) { (p, e) in
                if let e = e {
                    error("Giveaway has come across an error", error: e.localizedDescription, inReplyTo: msg)
                } else if let modifier = p.modifier {
                    // MARK: Setup
                    if modifier == "setup" {
                        Giveaway.manager.setup(msg: msg)
                    } else if modifier == "reset" {
                        // MARK: Reset
                        Giveaway.manager.reset()
                        EmbedReply().reply(to: msg, title: "Your giveaway has been reset", message: "You may now start a new giveaway", color: .system)
                    } else if modifier == "start" {
                        // MARK: Start
                        Giveaway.manager.start(msg: msg)
                    } else if modifier == "reroll" {
                        // MARK: Reroll
                        Giveaway.manager.reroll(msg: msg)
                    } else if modifier == "finish" {
                        // MARK: Finish
                        Giveaway.manager.finish(msg: msg)
                    } else {
                        error("Giveaway manager doesn't know how to do this!", inReplyTo: msg)
                    }
                } else {
                    error("Error, this command requires additional arguments", inReplyTo: msg)
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
