//
//  RoleManager.swift
//  AppleBot
//
//  Created by Erik Bean on 5/10/18.
//

import Foundation
import Sword

var rmRole:String?
var rmCategory:String?
var rmEmoji:String?
var rmStageOption:String?

class RoleManager {
    static let shared = RoleManager()
    private init() {}
    
    // MARK:- Role Manager
    
    func rm(msg: Message, parser: Parser) {
        switch parser.modifier {
        case "display":
            if let roles = assignableRoles[Parser.getGuildID(msg: msg)] {
                var list = String()
                for role in roles {
                    list.append("\(role.key)\n")
                }
                if list == "" {
                    list.append(" No roles assignable")
                }
                EmbedReply().reply(to: msg, title: "Role Manager", message: list, color: .system)
            }
        case "setup":
            /// This needs to be rewritten vs the old setup, old code commented and attached
            
//            msg.member?.user.getDM(then: { (dm, e) in
//                if e != nil {
//                    error("An error has occured", error: e!.message, inReplyTo: msg)
//                } else {
//                    if let dm = dm {
//                        roleSetup = true
//                        let message = """
//                        Welcome to Apple Bot Role Manager setup!
//
//                        To help make setting up and displaying roles simpler, roles are seporated into categories. You can use the default category for all roles, or setup custom categories
//
//                        What would you like to do?
//
//                        **1:** Use the default category
//                        **2:** Setup a new category
//                        """
//                        dm.send(message)
//                        rmStageOption = "setup"
//                    } else {
//                        error("Dm missing", inReplyTo: msg)
//                    }
//                }
//            })
            
            return
        case "help":
            EmbedReply().reply(to: msg, title: "Welcome to Role Manager", message: "No help has been setup yep... Ummm.... Good Luck?", color: .testing)
        default:
            EmbedReply().error(on: msg, error: "Unknown Modifier")
            return
        }
    }
    
    // MARK:- Role Manager - Add
    
    func rma(msg: Message, parser: Parser) {
        let guild = Parser.getGuildID(msg: msg)
        let guildSnowflake = Snowflake(rawValue: guild)
        switch parser.modifier {
        case "all":
            bot.getRoles(from: guildSnowflake) { (roles, e) in
                if let e = e {
                    error("Could not find roles", error: e.message, inReplyTo: msg)
                } else if let roles = roles {
                    var newRoles = [String: UInt64]()
                    for role in roles {
                        if role.permissions == 104324151 && role.name != "@everyone" {
                            newRoles[role.name] = role.id.rawValue
                        }
                    }
                    assignableRoles[guild] = newRoles
                    EmbedReply().reply(to: msg, title: "All available are now added to the Role Manager.", message: "You can use `\(indicator[Parser.getGuildID(msg: msg)] ?? "!")rm display` to view all currently assignable roles", color: .system)
                } else {
                    error("No Roles Found", inReplyTo: msg)
                }
            }
        case "help":
            let welcome = """
            To use this command, type `rma` followed by one of the following:

            `all` **:** *Add all of the roles available to Apple Bot will be used. This will overwrite any current roles.*
            `@[role]`**:** *The tagged role will be added to the available role list*
            `[role ID]`**:** *The role with this ID will be added to the available role list*
            `display`**:** *View the current list of possible roles that can be added to Apple Bot*
            """
            EmbedReply().reply(to: msg, title: "Welcome to the Apple Bot Automatic Role Manager: `Add` Command", message: welcome, color: .apple)
        case "display":
            bot.getRoles(from: guildSnowflake) { (roles, e) in
                if let e = e {
                    error("Could not find roles", error: e.message, inReplyTo: msg)
                } else if let roles = roles {
                    var list = "*Tip: To remove something from this list, simply change it's permissions to non-default permissions!*\n\n"
                    for role in roles {
                        if role.permissions == 104324161 && role.name != "@everyone" {
                            list.append("\(role.name)\n")
                        }
                    }
                    EmbedReply().reply(to: msg, title: "List of roles that can be added", message: list, color: .system)
                } else {
                    error("No Roles Found", inReplyTo: msg)
                }
            }
        default:
            bot.getRoles(from: guildSnowflake) { (roles, e) in
                if let e = e {
                    error("Could not find roles", error: e.message, inReplyTo: msg)
                } else if let roles = roles {
                    var nr = parser.modifier!
                    if let remainder = parser.remainder {
                        nr.append(remainder)
                    }
                    for role in roles {
                        if role.name == nr {
                            if var r = assignableRoles[guild] {
                                r[role.name] = role.id.rawValue
                                assignableRoles[guild] = r
                            } else {
                                assignableRoles[guild] = [role.name: role.id.rawValue]
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK:- Role Manager - Remove
    
    func rmr(msg: Message, parser: Parser) {
        let guild = Parser.getGuildID(msg: msg)
        switch parser.modifier {
        case "all":
            assignableRoles[guild] = nil
        case "display":
            guard let roles = assignableRoles[guild] else {
                error("There are no roles to be removed", inReplyTo: msg)
                return
            }
            var list = String()
            for role in roles {
                list.append("\(role.key)\n")
            }
            EmbedReply().reply(to: msg, title: "You can remove the following roles", message: list, color: .system)
        case "help":
            let welcome = """
            To use this command, type `rma` followed by one of the following:

            `all` **:** *Remove all of the roles, this will disable users from adding roles themselves.*
            `@[role]`**:** *The tagged role will be removed from the available role list*
            `[role ID]`**:** *The role with this ID will be removed from the available role list*
            `display`**:** *View the current list of possible roles that can be removed from Apple Bot*
            """
            EmbedReply().reply(to: msg, title: "Welcome to the Apple Bot Automatic Role Manager: `Add` Command", message: welcome, color: .apple)
        default:
            if let remainder = parser.remainder {
                var role = remainder.lowercased()
                if remainder.first! == "@" {
                    role = remainder.dropFirst().lowercased()
                } else if let roles = assignableRoles[guild] {
                    if roles.keys.contains(role) {
                        assignableRoles[guild]![role] = nil
                        EmbedReply().reply(to: msg, title: "The role \(role) has been removed from list of self assignable roles", message: nil, color: .system)
                    } else {
                        error("Role is not self assignable or does not exist", inReplyTo: msg)
                    }
                } else {
                    error("There was an error removing your role", inReplyTo: msg)
                }
            }
        }
    }
    
    // MARK:- Role Manager - Self Commands
    
    func giverole(msg: Message, parser: Parser) {
        let guild = Parser.getGuildID(msg: msg)
        if let remainder = parser.remainder {
            if let roles = assignableRoles[guild] {
                let keys = roles.keys
                if keys.contains(remainder) {
                    let role = Snowflake(rawValue: roles[remainder]!)
                    if let accuser = parser.accusor {
                        var rawRoles = [role.rawValue]
                        for role in msg.member!.roles {
                            rawRoles.append(role.id.rawValue)
                        }
                        bot.modifyMember(accuser.id, in: msg.member!.guild!.id, with: ["roles": rawRoles]) { e in
                            if let e = e {
                                if e.code == 50035 {
                                    error("Oh No! It looks like already have this role!", inReplyTo: msg)
                                } else {
                                    error("Error Assigning Role!", error: String(describing: e.error), inReplyTo: msg)
                                }
                            } else {
                                EmbedReply().reply(to: msg, title: "You have been given the role \(parser.remainder!)", message: nil, color: .apple)
                            }
                        }
                    } else {
                        error("User Not Found", inReplyTo: msg)
                    }
                } else {
                    error("Role Not Found, please ensure there are assignable roles.", inReplyTo: msg)
                }
            } else {
                error("Roles Not Found", inReplyTo: msg)
            }
        } else {
            error("This command requires more information", inReplyTo: msg)
        }
    }
    
    func removerole(msg: Message, parser: Parser) {
        let guild = Parser.getGuildID(msg: msg)
        if let reminder = parser.remainder {
            if let ars = assignableRoles[guild] {
                if let roles = Parser.getRoles(msg: msg) {
                    var rIDs = [UInt64]()
                    for role in roles {
                        if role.id.rawValue != ars[reminder] {
                            rIDs.append(role.id.rawValue)
                        }
                    }
                    guard rIDs.count != roles.count else {
                        error("Role not found", inReplyTo: msg)
                        return
                    }
                    if let accuser = parser.accusor {
                        bot.modifyMember(accuser.id, in: msg.member!.guild!.id, with: ["roles": rIDs]) { e in
                            if let e = e {
                                error("Error: Could not remove role", error: e.message, inReplyTo: msg)
                            } else {
                                EmbedReply().reply(to: msg, title: "The role has been successfully removed", message: nil, color: .apple)
                            }
                        }
                    } else {
                        error("An Error Occured", error: "Your roles could not be edited at this time, please try again.", inReplyTo: msg)
                    }
                } else {
                    error("You have no roles to remove", inReplyTo: msg)
                }
            } else {
                error("This server has no roles you can remove yourself, ask an Admin or Mod to remove them for you!", inReplyTo: msg)
            }
        }
    }
}
