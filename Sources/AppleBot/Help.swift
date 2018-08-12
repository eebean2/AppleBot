//
//  Help.swift
//  AppleBot
//
//  Created by Erik Bean on 5/13/18.
//

import Sword

// TODO: Redo the help documentation for users

class help {
    func getHelp(dm: DM, msg: Message) {
        Parser().parse(msg: msg, hasModifier: false) { (p, e) in
            if e != nil {
                error("There was an error getting help", error: "Please try again later", inReplyTo: msg)
            } else {
                var restricted = [[String: [UInt64]]]()
                if commandPerms[Parser.getGuildID(msg: msg)] != nil {
                    restricted = commandPerms[Parser.getGuildID(msg: msg)]!
                }
                var roles = [UInt64]()
                if Parser.getRoles(msg: msg) != nil {
                    for role in Parser.getRoles(msg: msg)! {
                        roles.append(role.id.rawValue)
                    }
                }
                
                print(restricted)
                
                let mod = p.remainder
                if mod == nil {
                    var h = String()
                    h.append("\(rm)\n")
                    h.append("\(rma)\n")
                    h.append("\(rmr)\n")
                    h.append("\(giverole)\n")
                    h.append("\(removerole)\n")
                    h.append("\(ping)\n")
                    h.append("\(shutdown)\n")
                    h.append("\(whoami)\n")
                    h.append("\(limitcommand)\n")
                    h.append("\(uptime)\n")
                    h.append("\(setstatus)\n")
                    h.append("\(approved)\n")
                    h.append("\(permcheck)\n")
                    h.append("\(help)\n")
                    let embed = EmbedReply.getEmbed(withTitle: "Welcome to Apple Bot", message: h, color: .apple)
                    dm.send(embed)
                    EmbedReply().reply(to: msg, title: "Check your DM's!", message: nil, color: .apple)
                }
            }
        }
    }
    
    let rm: String = "**`rm`:** *Role Manager, allows you to access the role manager. This command requires a modifier. You can use `rm help` for more details.*"
    let rma: String = "**`rma`:** *Role Manager Add, allows you to add roles to the role manager for user self adding. This command requires a modifier. You can use `rma help` for more details.*"
    let rmr: String = "**`rmr`:** *Role Manager Remove, allows you to remove roles from the role manager to stop self adding. This command requires a modifier. You can use `rmr help` for more details.*"
    let giverole: String = "**`giverole` or `gvr`:** *Give Role, allows you to assign yourself a role.*"
    let removerole: String = "**`removerole` or `tkr`:** *Remove Role, allows you to remove a role from yourself.*"
    let ping: String = "**`ping`:** *Ping, ping the bot.*"
    let shutdown: String = "**`shutdown`:** *Shutdown, DO IT, END MY BLOODY SUFFERING!*"
    let whoami: String = "**`whoami`:** *Who Am I, find out more about me.*"
    let limitcommand: String = "**`limitcommand`:** *Limit Command, limit commands to specific roles. This command requires a modifier. This will be moved under Role Manager in the future.*"
    let uptime: String = "**`uptime`:** *Uptime, check how long the bot has been alive in seconds.*"
    let setstatus: String = "**`setstatus`:** *Set Status, set the playing game status of the bot.*"
    let approved: String = "**`approved`:** *Approved, check if your server is approved to use Apple Bot.*"
    let permcheck: String = "**`permcheck`:** *Permission Check, check your current permission limitations*"
    let help: String = "**`help`:** *Help, the command you just asked for...*"
}
