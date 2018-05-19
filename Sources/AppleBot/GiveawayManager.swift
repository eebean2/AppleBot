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
            if msg.member != nil {
                
            }
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
