//
//  GiveawayManager.swift
//  AppleBot
//
//  Created by Erik Bean on 5/18/18.
//

import Sword
import Foundation

class Giveaway {
    
    static let manager = Giveaway()
    
    private(set) var isSetup = false
    
    private var tobegiven: String = "Oh... um... this is awkward.... it's Nothing (someone didn't set this up right)!"
    private var drawOn: Date?
    
    private init() {}
    
    private func setup(msg: Message) {
        if isSetup {
            
        }
        if roleSetup == .noSetup {
            let welcome = """
            At anytime during this process, simply type "exit" to cancel the giveaway setup process.

            To start off, tell me what you want to giveaway?
            """
            let e = EmbedReply.getEmbed(withTitle: "Welcome to Apple Bot Giveaway Manager", message: welcome, color: .apple)
            if msg.member != nil {
                sendDM(msg: msg, embed: e) { success in
                    if !success {
                        error("Giveaway setup has been aborted", inReplyTo: msg)
                    } else {
                        roleSetup = .giveawayNeedsItem
                    }
                }
            }
        } else if roleSetup == .giveawayNeedsItem {
            tobegiven = msg.content
            let message = """
            \(tobegiven)
            
            Next, I need to know how long you want the giveaway to last! In the format of 000d (d = days and h = hours), tell me how long till I can pick a winner!
            """
            let e = EmbedReply.getEmbed(withTitle: "You are giving away:", message: message, color: .apple)
            sendDM(msg: msg, embed: e, completion: { success in
                if !success {
                    error("Giveaway setup has been aborted", inReplyTo: msg)
                    return
                } else {
                    roleSetup = .giveawayNeedsDate
                }
            })
        } else if roleSetup == .giveawayNeedsDate {
            
            // Set time, display setup message, and tell uerer to use `giveaway start`
            
        }
    }
    
    func start() {
        drawOn = Date()
        let df = DateFormatter()
        df.locale = NSLocale.current
        df.dateStyle = DateFormatter.Style.full
        let convDate = df.string(from: drawOn!)
        let giveaway = """
        It's that time again! Another /r/Apple Discord Giveaway!

        Here is what we are giving away this time:
                `\(tobegiven)`
        
        You have till \(convDate) to hit that :tickets: reaction below
        """
        bot.send(giveaway, to: Snowflake(rawValue: testChannel))
        bot.getMessages(from: Snowflake(rawValue: testChannel)) { (messages, err) in
            if let err = err {
                print(err)
            } else if let messages = messages {
                if messages.last?.content == giveaway {
                    
                    // Add emoji to message
                    
                } else {
                    
                    // Message is not last, error and remove giveaway message
                    
                }
            }
        }
    }
}

func sendDM(msg: Message, embed: Embed, completion: @escaping (Bool) -> Void) {
    bot.getDM(for: msg.member!.user.id) { (dm, e) in
        if let e = e {
            error("There was an error", error: e.message, inReplyTo: msg)
            completion(false)
        } else {
            if let dm = dm {
                dm.send(embed)
                completion(true)
            } else {
                error("Could not find DM", inReplyTo: msg)
                completion(false)
            }
        }
    }
}
