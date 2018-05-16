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
                    l.append("\(r.key)\n")
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
    
    // MARK:- Role Manager - Add
    
    func rma(msg: Message, parser: Parser) {
        if parser.modifier!.lowercased() == "all" {
            bot.getRoles(from: Snowflake(rawValue: Parser.getGuildID(msg: msg))) { (roles, e: RequestError?) in
                if e != nil {
                    error("Could not find roles", error: e!.message, inReplyTo: msg)
                } else {
                    if roles != nil {
                        let g = Parser.getGuildID(msg: msg)
                        assignableRoles[g] = nil
                        var r = [String: UInt64]()
                        for role in roles! {
                            if role.permissions == 104324161 {
                                if role.name != "@everyone" {
                                    r[role.name] = role.id.rawValue
                                }
                            }
                        }
                        assignableRoles[g] = r
                        EmbedReply().reply(to: msg, title: "All available are now ready to be added.", message: "You can use `\(indicator[Parser.getGuildID(msg: msg)] ?? "!")rm display` to view all currently available roles", color: .system)
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
                                var r = assignableRoles[Parser.getGuildID(msg: msg)]!
                                r[role.name] = role.id.rawValue
                                assignableRoles[Parser.getGuildID(msg: msg)]! = r
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
    
    // MARK:- Role Manager - Remove
    
    func rmr(msg: Message, parser: Parser) {
        if parser.modifier!.lowercased() == "all" {
            assignableRoles[Parser.getGuildID(msg: msg)] = nil
        } else if parser.modifier!.lowercased() == "help" {
            rmaHelp(msg: msg)
        } else if parser.modifier!.lowercased() == "display" {
            guard assignableRoles[Parser.getGuildID(msg: msg)] != nil else {
                error("There are no roles to be removed", inReplyTo: msg)
                return
            }
            var list = String()
            for role in assignableRoles[Parser.getGuildID(msg: msg)]! {
                list.append("\(role.key)\n")
            }
            EmbedReply().reply(to: msg, title: "You can remove the following roles", message: list, color: .system)
        } else {
            if parser.remainder != nil {
                var role = parser.remainder!.lowercased()
                if parser.remainder!.first! == "@" {
                    role = parser.remainder!.dropFirst().lowercased()
                }
                if assignableRoles[Parser.getGuildID(msg: msg)] != nil {
                    assignableRoles[Parser.getGuildID(msg: msg)]![role] = nil
                    EmbedReply().reply(to: msg, title: "If the role existed, it has been removed from the assignable role list", message: nil, color: .system)
                }
            }
        }
    }
    
    func rmrHelp(msg: Message) {
        let welcome = """
            To use this command, type `rma` followed by one of the following:

            `all` **:** *Remove all of the roles, this will disable users from adding roles themselves.*
            `@[role]`**:** *The tagged role will be removed from the available role list*
            `[role ID]`**:** *The role with this ID will be removed from the available role list*
            `display`**:** *View the current list of possible roles that can be removed from Apple Bot*
            """
        EmbedReply().reply(to: msg, title: "Welcome to the Apple Bot Automatic Role Manager: `Add` Command", message: welcome, color: .apple)
    }
    
    // MARK:- Role Manager - Self Commands
    
    func giverole(msg: Message, parser: Parser) {
        let keys = assignableRoles[Parser.getGuildID(msg: msg)]?.keys
        if parser.remainder != nil {
            if let keys = keys, keys.contains(parser.remainder!) {
                let roles = assignableRoles[Parser.getGuildID(msg: msg)]!
                let role = Snowflake(rawValue: roles[parser.remainder!]!)
                if parser.accusor != nil {
                    let roles = msg.member!.roles
                    var rawroles = [UInt64]()
                    for role in roles {
                        rawroles.append(role.id.rawValue)
                    }
                    rawroles.append(role.rawValue)
                    print(rawroles)
                    bot.modifyMember(parser.accusor!.id, in: msg.member!.guild!.id, with: ["roles": rawroles]) { e in
                        if e != nil {
                            if e!.code == 50035 {
                                error("Oh No! It looks like already have this role!", inReplyTo: msg)
                            } else {
                                error("Error Assigning Role!", error: String(describing: e!.error), inReplyTo: msg)
                            }
                        } else {
                            EmbedReply().reply(to: msg, title: "You have been given the role \(parser.remainder!)", message: nil, color: .apple)
                        }
                    }
                }
            } else {
                error("Role Not Found", inReplyTo: msg)
            }
        }
    }
    
    func removerole(msg: Message, parser: Parser) {
        guard let roles = Parser.getRoles(msg: msg) else {
            error("You have no roles to remove", inReplyTo: msg)
            return
        }
        guard let ars = assignableRoles[Parser.getGuildID(msg: msg)] else {
            error("This server has no roles you can remove yourself, ask an Admin or Mod to remove them for you!", inReplyTo: msg)
            return
        }
        if let remainder = parser.remainder {
            let toBeRemoved = ars[remainder]
            var rIDs = [UInt64]()
            for role in roles {
                if role.id.rawValue != toBeRemoved {
                    rIDs.append(role.id.rawValue)
                }
            }
            if rIDs.count == roles.count {
                error("Role not found", inReplyTo: msg)
            } else {
                if let accuser = parser.accusor {
                    bot.modifyMember(accuser.id, in: msg.member!.guild!.id, with: ["roles" : rIDs]) { (e) in
                        if e != nil {
                            error("Error: Could not remove role", error: e!.message, inReplyTo: msg)
                        } else {
                            EmbedReply().reply(to: msg, title: "The role has been successfully removed", message: nil, color: .apple)
                        }
                    }
                } else {
                    error("An Error Occured", error: "Your roles could not be edited at this time, please try again.", inReplyTo: msg)
                }
            }
        }
    }
    
    // MARK:- Role Manager - Reaction Commands
    
    
}
