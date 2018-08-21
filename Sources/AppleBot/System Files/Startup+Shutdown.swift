//
//  Startup+Shutdown.swift
//  AppleBot
//
//  Created by Erik Bean on 5/8/18.
//

import Foundation
import Sword

// MARK:- Startup

var t: ABTimer!

func botStartup() {
    bot.editStatus(to: "online")
    message("Apple Bot is Now Starting", message: "Commands will not be usable until Apple Bot is fully loaded")
    ABLogger.log(action: "~~ Startup Started ~~")
    isSaving = true
    #if os(macOS)
    var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    #else
    var path = Bundle.main.executablePath!
    #endif
    path.append("/Preferences/com.AppleBot.botprefs.plist")
    ABLogger.log(action: "Loading settings from \(path)")
    if let plist = FileManager.default.contents(atPath: path) {
        if let dict = NSKeyedUnarchiver.unarchiveObject(with: plist) {
            Parser().parsePreferances(from: dict as! NSDictionary)
            ABLogger.log(action: "Settings loaded")
        } else {
            ABLogger.log(action: "No settings found, using defaults. These will be saved next time you shutdown. You will have to custimize the bot commands, status, and more. Use !help to access the quick help guide.")
            error("No settings found, using defaults.", error: "These will be saved next time you shutdown. You will have to custimize the bot commands, status, and more. Use !help to access the quick help guide.")
        }
    }
    ABLogger.log(action: "Pulling out the censorship guns")
    ABCensor.main.lockAndLoad()
    ABLogger.log(action: "Setting up GCD Timer (ABTimer) to clean up logs")
    t = ABTimer(timeInterval: 86400, repeats: true) { timer in
        ABLogger.log(action: "Timer setup, cleaning up logs, will repeat every 24 hours at this time.")
        ABLogger.logger.cleanupLogs()
    }
    ABLogger.log(action: "Setting bot status to online, status is \"\(status)\"")
    bot.editStatus(to: "online", playing: status)
    ABLogger.log(action: "Loading infraction tables")
    InfractionManagement().checkInfractionTables()
    isSaving = false
    message("Apple Bot is ready to use!")
    ABLogger.log(action: "~~ Startup Finished ~~")
}

// MARK:- Shutdown

func botShutdown(msg: Message? = nil, forced: Bool = false) {
    message("Starting Shutdown", message: "Please do not force shutdown, attempt commands, or yell at me (I'm trying my hardest here)", inReplyTo: msg)
    message("Saving Preferances", inReplyTo: msg)
    ABLogger.log(action: "~~ Shutdown Initiated ~~")
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
    ABLogger.log(action: "~~ Shutdown Completed ~~")
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
    var logString = "ERROR: \(title)"
    if error != nil {
        logString.append(" | \(error!)")
    }
    ABLogger.log(action: logString)
    let e = EmbedReply.getEmbed(withTitle: title, message: error, color: .alert)
    if let msg = msg {
        msg.reply(with: e)
    } else {
        bot.send(e, to: Snowflake(rawValue: testChannel))
    }
}

func diag(_ msg: String) {
    ABLogger.log(action: "DIAGNOSTIC MESSAGE: \(msg)")
    let e = EmbedReply.getEmbed(withTitle: "Diagnostic Message", message: msg, color: .testing)
    bot.send(e, to: Snowflake(rawValue: testChannel))
}

// MARK:- Force Save

func forceSave(msg: Message) {
    message("Saving Preferances", inReplyTo: msg)
    ABLogger.log(action: "~~ Force Saving ~~")
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
            ABLogger.log(action: "~~ Force Save Successful ~~")
        } else {
            error("Unable to save preferances", inReplyTo: msg)
        }
    } else {
        let d = NSKeyedArchiver.archivedData(withRootObject: perms)
        if FileManager.default.createFile(atPath: path, contents: d, attributes: nil) {
            message("Preferances Successfully Saved", inReplyTo: msg)
            ABLogger.log(action: "~~ Force Save Successful ~~")
        } else {
            error("Unable to save preferances", inReplyTo: msg)
        }
    }
    isSaving = false
}

func loadToken() -> String {
    ABLogger.log(action: "NOTICE: Bot Token Requested")
    #if os(macOS)
    var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
    #else
    var path = Bundle.main.executablePath!
    #endif
    path.append("/AppleBot/token.txt")
    if FileManager.default.fileExists(atPath: path) {
        do {
            return try String(contentsOf: URL(fileURLWithPath: path))
        } catch let error {
            ABLogger.log(action: "NOTICE: An error occurred when attempting to load the token. ERROR: \(error.localizedDescription)")
            fatalError("Could not load Bot Token. Error: \(error.localizedDescription)")
        }
    } else {
        ABLogger.log(action: "NOTICE: An error occurred when attempting to load the bot token. ERROR: Token does not exist at \(path)")
        fatalError("Could not load Bot Token. Error: Token does not exist at \(path)")
    }
}
