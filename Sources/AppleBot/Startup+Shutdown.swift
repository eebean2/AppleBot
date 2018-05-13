//
//  Startup+Shutdown.swift
//  AppleBot
//
//  Created by Erik Bean on 5/8/18.
//

import Foundation
import Sword

// MARK:- Startup

func botStartup() {
    bot.editStatus(to: "online")
    message("Apple Bot is Now Starting")
    message("Loading Settings", message: "Commands will not be usable until all settings are loaded")
    isSaving = true
    var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    path.append("/Preferences/com.AppleBot.botprefs.plist")
    let plist = FileManager.default.contents(atPath: path)
    if plist != nil {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: plist!) as? NSDictionary
        if dict != nil {
            Parser().parsePreferances(from: dict!)
            message("Settings Loaded")
        } else {
            error("No settings found, using defaults.", error: "These will be saved next time you shutdown. You will have to custimize the bot commands, status, and more. Use !help to access the quick help guide.")
        }
    } else {
        error("No settings file found, using defaults.", error: "This file will be created next time you shutdown. You will have to custimize the bot commands, status, and more. Use !help to access the quick help guide.")
    }
    bot.editStatus(to: "online", playing: status)
    InfractionManagement().checkInfractionTables()
    isSaving = false
    message("Apple Bot is ready to use!")
}

// MARK:- Shutdown

func botShutdown(msg: Message? = nil) {
    message("Starting Shutdown", message: "Please do not force shutdown, attempt commands, or yell at me (I'm trying my hardest here)", inReplyTo: msg)
    message("Saving Preferances", inReplyTo: msg)
    isSaving = true
    let perms = Parser().getPreferances()
    var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    path.append("/Preferences/com.AppleBot.botprefs.plist")
    if FileManager.default.fileExists(atPath: path) {
        let s = NSKeyedArchiver.archiveRootObject(perms, toFile: path)
        if !s {
            error("Unable to save preferances", inReplyTo: msg)
// Add forced shutdown here
        } else {
            message("Preferances Successfully Saved", inReplyTo: msg)
        }
    } else {
        let d = NSKeyedArchiver.archivedData(withRootObject: perms)
        FileManager.default.createFile(atPath: path, contents: d, attributes: nil)
        message("Preferances Successfully Saved", inReplyTo: msg)
    }
    isSaving = false
    message("Thank you for using Apple Bot", inReplyTo: msg)
    bot.disconnect()
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        exit(EXIT_SUCCESS)
    }
}

// MARK:- Helper Functions

func message(_ title: String, message: String? = nil, inReplyTo msg: Message? = nil) {
    let e = EmbedReply.getEmbed(withTitle: title, message: message, color: .system)
    if msg != nil {
        msg!.reply(with: e)
    } else if testChannel != nil {
        bot.send(e, to: Snowflake(rawValue: testChannel!))
    }
}

func error(_ title: String, error: String? = nil, inReplyTo msg: Message? = nil) {
    let e = EmbedReply.getEmbed(withTitle: title, message: error, color: .alert)
    if msg != nil {
        msg!.reply(with: e)
    } else if testChannel != nil {
        bot.send(e, to: Snowflake(rawValue: testChannel!))
    }
}