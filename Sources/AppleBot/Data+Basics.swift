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
let approvedServers: [UInt64] = [406145333916205076, 332309672486895637, 337792272693461002]

/// The all mighty Wookiee (replace to use the creator functions)
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
/// Structured [Guild: [Role Name: Role ID]]
var assignableRoles = [UInt64: [Role]]()





/// Apple Bot command compliance check
enum Command: String {
    case test = "test"
    case uptime = "uptime"
    case limitCommand = "limitcommand"
    
    var string: String { return toString() }
    
    private func toString() -> String {
        return self.rawValue
    }
}
