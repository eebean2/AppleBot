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
private let _botToken: [UInt8] = [78, 68, 77, 48, 77, 84, 85, 53, 78, 84, 85, 52, 77, 122, 69, 120, 78, 84, 81, 121, 78, 122, 103, 48, 46, 68, 105, 104, 73, 106, 103, 46, 119, 87, 79, 117, 112, 112, 49, 80, 83, 115, 85, 79, 80, 55, 111, 52, 57, 67, 97, 85, 54, 78, 114, 68, 65, 122, 56]

/// Guilds approved for use with Apple Bot
let approvedServers: [UInt64] = [406145333916205076, 450744862883577858]

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

/// Bot Token for interacting with the Discord API
var botToken: String { return String(bytes: _botToken, encoding: .utf8) ?? "" }

/// Where the bot channel is located for a guild
var botChannel: [UInt64: UInt64] = [406145333916205076: 441783256699109386]

/// Giveaway Channel
var giveChannel: [UInt64: UInt64] = [406145333916205076: 441783256699109386]

/// Giveaway Role
var giveRole: [UInt64: String] = [406145333916205076: "@everyone"]

/// The test channel
/// This is where information for startups, failures, and general logging is located
/// Change this to your general test channel if you wish to see this information
var testChannel: UInt64 = 441783256699109386

/// The Apple Bot default status
var status: String = "with my WWDC Ticket"

/// Assignable roles
///
/// Structured [Guild: [Role Name: Role ID (Snowflake)]]
var assignableRoles = [UInt64: [String: UInt64]]()

/// The version of Apple Bot Running
let version: String = "I'm a test version designed and ran by Wookiee, bite my hairy Wookiee ass!"

/// Commands for only the creator
let creatorcommands = ["shutdown, setstatus"]

/// Role Manager Setup
var roleSetup: SetupState = .noSetup



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
    case shutdown = "shutdown"
    case whoami = "whoami"
    case limitCommand = "limitcommand"
    case uptime = "uptime"
    case setstatus = "setstatus"
    case approved = "approved"
    case permcheck = "permcheck"
    case help = "help"
    case setIndicator = "setindicator"
    case saveprefs = "saveprefs"
    case tempmute = "tempmute"
    case giveaway = "giveaway"
    
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

/// Setup State
enum SetupState {
    case noSetup
    case giveawayNeedsItem
    case giveawayNeedsWinners
    case giveawayNeedsDate
}
