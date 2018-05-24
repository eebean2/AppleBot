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
    #if os(macOS)
    var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    #else
    var path = Bundle.main.executablePath!
    #endif
    path.append("/Preferences/com.AppleBot.botprefs.plist")
    if let plist = FileManager.default.contents(atPath: path) {
        if let dict = NSKeyedUnarchiver.unarchiveObject(with: plist) {
            Parser().parsePreferances(from: dict as! NSDictionary)
            message("Settings Loaded")
        } else {
            error("No settings found, using defaults.", error: "These will be saved next time you shutdown. You will have to custimize the bot commands, status, and more. Use !help to access the quick help guide.")
        }
    }
    bot.editStatus(to: "online", playing: status)
    InfractionManagement().checkInfractionTables()
    isSaving = false
    message("Apple Bot is ready to use!")
}

// MARK:- Shutdown

func botShutdown(msg: Message? = nil, forced: Bool = false) {
    message("Starting Shutdown", message: "Please do not force shutdown, attempt commands, or yell at me (I'm trying my hardest here)", inReplyTo: msg)
    message("Saving Preferances", inReplyTo: msg)
    isSaving = true
    let perms = Parser().getPreferances()
    #if os(macOS)
    var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    #else
    var path = Bundle.main.executablePath!
    #endif
    path.append("/Preferences/com.AppleBot.botprefs.plist")
    if FileManager.default.fileExists(atPath: path) {
        if NSKeyedArchiver.archiveRootObject(perms, toFile: path) {
            message("Preferances Successfully Saved", inReplyTo: msg)
            isSaving = false
            shutdown(msg: msg)
        } else {
            error("Unable to save preferances", inReplyTo: msg)
            isSaving = false
            if !forced {
                error("Aborting Shutdown", error: "To force shutdown, add `forced` after the shurdown command", inReplyTo: msg)
                return
            } else {
                shutdown(msg: msg)
            }
        }
    } else {
        let d = NSKeyedArchiver.archivedData(withRootObject: perms)
        if FileManager.default.createFile(atPath: path, contents: d, attributes: nil) {
            message("Preferances Successfully Saved", inReplyTo: msg)
            isSaving = false
            shutdown(msg: msg)
        } else {
            error("Unable to save preferances", inReplyTo: msg)
            isSaving = false
            if !forced {
                error("Aborting Shutdown", error: "To force shutdown, add `forced` after the shurdown command", inReplyTo: msg)
                return
            } else {
                shutdown(msg: msg)
            }
        }
    }
}

// MARK:- Helper Functions

private func shutdown(msg: Message?) {
    message("Thank you for using Apple Bot", inReplyTo: msg)
    bot.disconnect()
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        exit(EXIT_SUCCESS)
    }
}

func message(_ title: String, message: String? = nil, inReplyTo msg: Message? = nil) {
    let e = EmbedReply.getEmbed(withTitle: title, message: message, color: .system)
    if let msg = msg {
        msg.reply(with: e)
    } else {
        bot.send(e, to: Snowflake(rawValue: testChannel))
    }
}

func error(_ title: String, error: String? = nil, inReplyTo msg: Message? = nil) {
    let e = EmbedReply.getEmbed(withTitle: title, message: error, color: .alert)
    if let msg = msg {
        msg.reply(with: e)
    } else {
        bot.send(e, to: Snowflake(rawValue: testChannel))
    }
}

func diag(_ msg: String) {
    let e = EmbedReply.getEmbed(withTitle: "Diagnostic Message", message: msg, color: .testing)
    bot.send(e, to: Snowflake(rawValue: testChannel))
}

// MARK:- Force Save

func forceSave(msg: Message) {
    message("Saving Preferances", inReplyTo: msg)
    isSaving = true
    let perms = Parser().getPreferances()
    #if os(macOS)
    var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    #else
    var path = Bundle.main.executablePath!
    #endif
    path.append("/Preferences/com.AppleBot.botprefs.plist")
    if FileManager.default.fileExists(atPath: path) {
        if NSKeyedArchiver.archiveRootObject(perms, toFile: path) {
            message("Preferances Successfully Saved", inReplyTo: msg)
        } else {
            error("Unable to save preferances", inReplyTo: msg)
        }
    } else {
        let d = NSKeyedArchiver.archivedData(withRootObject: perms)
        if FileManager.default.createFile(atPath: path, contents: d, attributes: nil) {
            message("Preferances Successfully Saved", inReplyTo: msg)
        } else {
            error("Unable to save preferances", inReplyTo: msg)
        }
    }
    isSaving = false
}
