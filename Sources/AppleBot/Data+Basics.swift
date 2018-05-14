//
//  Data+Basics.swift
//  AppleBot
//
//  Created by Erik Bean on 5/3/18.
//

// Super Friends :D = 406145333916205076

import Sword
import Foundation

/// Bot Token for interacting with the Discord API
let botToken: String = "NDM0MTU5NTU4MzExNTQyNzg0.DcvaGQ._jZ8rmuerkYJPiwsRPKwoTVo22k"

/// Guilds approved for use with Apple Bot
let approvedServers: [UInt64] = [406145333916205076, 393972674210168835, 332309672486895637]

/// The all mighty Wookiee (replace to use the creator commands)
let creator: UInt64 = 204675713813446656

/// The command indicator, what goes before the commands (!ping)
var indicator: [UInt64: String] = [406145333916205076: "*"]

/// Limit commands to specific roles, such as !ping to only mods and admins
/// This is structured as [Guild: [[Command: [Role]]]]
///
/// Example: [Apple Discord: [[Ping: [Mods, Admin], Test: [Admin]]]
var commandPerms: [UInt64: [[String: [UInt64]]]] = [406145333916205076:[[Command.uptime.string: [406159775815172108]]]]

/// Detect if the bot is saving or retriving information from disc
var isSaving = false

/// Where the bot channel is located for a guild
var botChannel: [UInt64: UInt64] = [406145333916205076: 441783256699109386]

/// The test channel
/// This is where information for startups, failures, and general logging is located
/// Change this to your general test channel if you wish to see this information
var testChannel: UInt64? = 441783256699109386

/// The Apple Bot default status
var status: String = "with my iPhone X"

/// Assignable roles
///
/// Structured [Guild: [Role Name: Role ID (Snowflake)]]
var assignableRoles = [UInt64: [String: UInt64]]()

/// The version of Apple Bot Running
let version: String = "I'm a test version designed and ran by Wookiee, bite my hairy Wookiee ass!"

/// Commands for only the creator
let creatorcommands = ["test", "shutdown"]



/// Apple Bot command compliance check
enum Command: String {
    case rm = "rm"
    case rma = "rma"
    case rmr = "rmr"
    case giverole = "giverole"
    case gvr = "gvr"
    case removerole = "removerole"
    case tkr = "tkr"
    case pint = "ping"
    case test = "test"
    case shutdown = "shutdown"
    case whoami = "whoami"
    case limitCommand = "limitcommand"
    case uptime = "uptime"
    case setstatus = "setstatus"
    case approved = "approved"
    case permcheck = "permcheck"
    case help = "help"
    
    var string: String { return toString() }
    
    private func toString() -> String {
        if self == .gvr {
            return Command.giverole.string
        } else if self == .tkr {
            return Command.removerole.string
        } else {
            return self.rawValue
        }
    }
}
