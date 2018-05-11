//
//  RoleManager.swift
//  AppleBot
//
//  Created by Erik Bean on 5/10/18.
//

import Foundation
import Sword

class RoleManager {
    
    // MARK:- Role Manager
    
    func rm(msg: Message, parser: Parser) {
        if parser.modifier!.lowercased() == "display" {
            var l = String()
            if let rl = assignableRoles[Parser.getGuildID(msg: msg)] {
                for r in rl {
                    l.append("\(r.name)\n")
                }
            }
            if l == "" {
                l.append("No roles assignable")
            }
            msg.reply(with: l)
        }
    }
    
    func rmHelp(msg: Message) {
        
    }
    
    // MARK:- Add to Automatic Role List
    
    func rma(msg: Message, parser: Parser) {
        if parser.modifier!.lowercased() == "all" {
            bot.getRoles(from: Snowflake(rawValue: Parser.getGuildID(msg: msg))) { (roles, e: RequestError?) in
                if e != nil {
                    error("Could not find roles", error: e!.message, inReplyTo: msg)
                } else {
                    if roles != nil {
                        let g = Parser.getGuildID(msg: msg)
                        assignableRoles[g] = nil
                        var r = [Role]()
                        for role in roles! {
                            if role.permissions == 104324161 {
                                if role.name != "@everyone" {
                                    r.append(role)
                                }
                            }
                        }
                        assignableRoles[g] = r
                    } else {
                        error("No roles found", inReplyTo: msg)
                    }
                }
            }
        } else if parser.modifier!.lowercased() == "help" {
            rmaHelp(msg: msg)
        } else if parser.modifier!.lowercased() == "display" {
            bot.getRoles(from: Snowflake(rawValue: Parser.getGuildID(msg: msg))) { (roles, e: RequestError?) in
                if e != nil {
                    error("Could not find roles", error: e!.message, inReplyTo: msg)
                } else {
                    EmbedReply().reply(to: msg, title: "Please check Xcode Logs for roles list", message: nil, color: .testing)
                    if roles != nil {
                        var l = "*Tip: To remove something from this list, simply change it's permissions to non-default permissions!*\n\n"
                        for role in roles! {
                            if role.permissions == 104324161 {
                                if role.name != "@everyone" {
                                    l.append("\(role.name)\n")
                                }
                            }
                        }
                        msg.reply(with: l)
                    } else {
                        error("No Roles Found", inReplyTo: msg)
                    }
                }
            }
        } else {
            bot.getRoles(from: Snowflake(rawValue: Parser.getGuildID(msg: msg))) { (roles, e) in
                if e != nil {
                    error("Could not find roles", error: e!.message, inReplyTo: msg)
                } else {
                    if roles != nil {
                        var nr = parser.modifier!
                        if parser.remainder != nil {
                            nr.append(" \(parser.remainder!)")
                        }
                        for role in roles! {
                            if role.name == nr {
                                assignableRoles[Parser.getGuildID(msg: msg)]!.append(role)
                            }
                        }
                    } else {
                        error("Could not find roles", inReplyTo: msg)
                    }
                }
            }
        }
    }
    
    func rmaHelp(msg: Message) {
        let welcome = """
            To use this command, type `rma` followed by one of the following:

            `all` **:** *Add all of the roles available to Apple Bot will be used. This will overwrite any current roles.*
            `@[role]`**:** *The tagged role will be added to the available role list*
            `[role ID]`**:** *The role with this ID will be added to the available role list*
            `display`**:** *View the current list of possible roles that can be added to Apple Bot*
            """
        EmbedReply().reply(to: msg, title: "Welcome to the Apple Bot Automatic Role Manager: `Add` Command", message: welcome, color: .apple)
    }
}
