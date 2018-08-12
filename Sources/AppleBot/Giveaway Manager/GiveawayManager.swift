//
//  GiveawayManager.swift
//  AppleBot
//
//  Created by Erik Bean on 5/18/18.
//

import Sword
import Foundation

// TODO: Rework me to be cross server compatible

class Giveaway {
    
    static let manager = Giveaway()
    
    private(set) var isSetup = false
    private(set) var isRunning = false
    
    private var tobegiven: String = "Oh... um... this is awkward.... it's Nothing (someone didn't set this up right)!"
    private var drawOn: Date?
    private var time: TimeInterval?
    private(set) var setupUser: User?
    private var id: UInt64?
    private(set) var numOfWinners: Int = 1
    private var drawPile = [UInt64]()
    
    private init() {}
    
    func setup(msg: Message) {
        if isRunning {
            error("There is already a giveaway running!", error: "Please let the giveaway finish, or use `giveaway reset` to remove it.", inReplyTo: msg)
            return
        } else if isSetup {
            error("There is already a giveaway setup!", error: "Use `giveaway start` to start the giveaway, or `giveaway reset` to remove it.", inReplyTo: msg)
            return
        }
        if roleSetup == .noSetup {
            EmbedReply().reply(to: msg, title: "Check your DM's!", message: nil, color: .system)
            setupUser = msg.author
            let welcome = """
            At anytime during this process, simply type "exit" to cancel the giveaway setup process.

            To start off, tell me what you want to giveaway?
            """
            let e = EmbedReply.getEmbed(withTitle: "Welcome to Apple Bot Giveaway Manager", message: welcome, color: .apple)
            if msg.member != nil {
                sendDM(msg: msg, embed: e) { success in
                    if !success {
                        error("Giveaway setup has been aborted", inReplyTo: msg)
                        Giveaway.manager.reset()
                    } else {
                        roleSetup = .giveawayNeedsWinners
                    }
                }
            }
        } else if roleSetup == .giveawayNeedsWinners {
            if msg.content == "exit" {
                msg.reply(with: "Giveaway canceled, you can resume your life now.")
                reset()
                return
            }
            tobegiven = msg.content
            let message = """
            `\(tobegiven)`
            
            Next, I need to know how many people we will be giving winning this giveaway!
            """
            let e = EmbedReply.getEmbed(withTitle: "You are giving away:", message: message, color: .apple)
            msg.reply(with: e)
            roleSetup = .giveawayNeedsItem
        } else if roleSetup == .giveawayNeedsItem {
            if msg.content == "exit" {
                msg.reply(with: "Giveaway canceled, you can resume your life now.")
                reset()
                return
            }
            if Int(msg.content) != nil && Int(msg.content)! > 0 {
                numOfWinners = Int(msg.content)!
            } else {
                error("The number of winners must be greater then 0!", error: "It also must be a number, just incase you were thinking of doing that", inReplyTo: msg)
                return
            }
            let message = """
            `\(numOfWinners)`
            
            Next, I need to know how long you want the giveaway to last! In the format of 000d (d = days, h = hours, and s = seconds), tell me how long till I can pick a winner!
            """
            let e = EmbedReply.getEmbed(withTitle: "You are giving away: \(tobegiven) to:", message: message, color: .apple)
            msg.reply(with: e)
            roleSetup = .giveawayNeedsDate
        } else if roleSetup == .giveawayNeedsDate {
            if msg.content == "exit" {
                msg.reply(with: "Giveaway canceled, you can resume your life now.")
                reset()
                return
            }
            let tIndicator = msg.content.last
            if var time = Double(msg.content.dropLast()) {
                switch tIndicator {
                case "d":
                    time = time * 86400
                case "m":
                    time = time * 60
                case "s": break
                default:
                    error("Invalid time indicator", error: "Please use the format `000x`, with 000 being the amount of time, and `x` being either d for days, m for minutes, or s for seconds.", inReplyTo: msg)
                    return
                }
                if time <= 300 {
                    self.time = time
                    let e = EmbedReply.getEmbed(withTitle: "Your giveaway is all setup!", message: "Just use `giveaway start` back in the server to start your giveaway!", color: .apple)
                    msg.reply(with: e)
                    roleSetup = .noSetup
                    isSetup = true
                } else {
                    error("Time cannot be less than 5 minuets!", error: "People need time to actually signup for the giveaway. Please enter a new time.", inReplyTo: msg)
                }
            }
        }
    }
    
    func start(msg: Message) {
        if isRunning {
            error("There is already a giveaway running!", error: "Please let the giveaway finish, or use `giveaway reset` to remove it.")
            return
        } else if !isSetup {
            error("Please setup a giveaway in order to start one!", error: "Use `giveaway setup` to setup the giveaway.")
            return
        }
        drawOn = Date().addingTimeInterval(time!)
        let df = DateFormatter()
        df.locale = NSLocale.current
        df.timeStyle = DateFormatter.Style.short
        df.dateStyle = DateFormatter.Style.full
        let convDate = df.string(from: drawOn!)
        guard let g = giveChannel[Parser.getGuildID(msg: msg)] else {
            error("Giveaway Channel not found", inReplyTo: msg)
            return
        }
        let guild = " \(bot.getGuild(for: Snowflake(rawValue: g))?.name ?? "")"
        
        let giveaway = """
        **It's that time again!** Another\(guild) Giveaway!

        Here is what we are giving away this time:
                **\(tobegiven)**
        
        You have till \(convDate) to hit that :tickets: reaction below
        """
        bot.send(giveaway, to: Snowflake(rawValue: g)) { (message, err) in
            if let err = err {
                error("Apple Bot had an error starting your giveaway, please try again", error: err.message)
            } else if let message = message {
                self.id = message.id.rawValue
                message.add(reaction: "🎟", then: { err in
                    if let err = err {
                        message.delete()
                        error("Apple Bot had an error starting your giveaway, please try again", error: err.message)
                    } else {
                        self.isRunning = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.time!, execute: {
                            self.draw(msg: message)
                        })
                    }
                })
            } else {
                error("Apple Bot had an unknown error starting your giveaway, please try again")
            }
        }
    }
    
    func reset() {
        roleSetup = .noSetup
        isSetup = false
        isRunning = false
        tobegiven = "Oh... um... this is awkward.... it's Nothing (someone didn't set this up right)!"
        drawOn = nil
        setupUser = nil
        drawPile = []
    }
    
    func addCheck(data: Any) {
        let (_, userID, messageID, emoji) = data as! (TextChannel, Snowflake, Snowflake, Emoji) // TexhChannel, UserID, MessageID, Emoji
        if userID.rawValue == 434159558311542784 {
            return
        }
        if messageID.rawValue == id && emoji.name == "🎟" {
            drawPile.append(userID.rawValue)
        }
    }
    
    func removeCheck(data: Any) {
        let (_, userID, messageID, emoji) = data as! (TextChannel, Snowflake, Snowflake, Emoji) // TexhChannel, UserID, MessageID, Emoji
        if messageID.rawValue == id && emoji.name == "🎟" {
            if let i = drawPile.index(of: userID.rawValue) {
                drawPile.remove(at: i)
            }
        }
    }
    
    func finish(msg: Message) {
        if !isRunning && !isSetup {
            error("No Giveaway Found", error: "Please use `giveaway setup` to start a new giveaway", inReplyTo: msg)
        }
        if drawOn! >= Date() {
            draw(msg: msg)
        } else {
            let time = drawOn!.timeIntervalSince(Date())
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.draw(msg: msg)
            }
        }
    }
    
    func reroll(msg: Message) {
        if drawPile.isEmpty {
            error("The draw pile is empty, sorry!", inReplyTo: msg)
        } else {
            let winner = drawPile.remove(at: Int(arc4random_uniform(UInt32(drawPile.count))))
            self.winners([winner], msg: msg)
        }
    }
    
    private func draw(msg: Message) {
        var winners = [UInt64]()
        repeat {
            winners.append(drawPile.remove(at: Int(arc4random_uniform(UInt32(drawPile.count)))))
        } while winners.count < numOfWinners
        self.winners(winners, msg: msg)
    }
    
    private func winners(_ ids: [UInt64], msg: Message) {
        var calls = String()
        for id in ids {
            calls.append("<@\(id)> ")
        }
        var s = String()
        if ids.count == 1 {
            s = """
            **We have a Winner!**

            The winner of **\(tobegiven)** is \(calls)
            """
        } else {
            s = """
            **We have Winners!**
            
            The winners of **\(tobegiven)** are \(calls)
            """
        }
        msg.reply(with: s)
    }
    
    func saveGiveaway() -> NSDictionary {
        if roleSetup != .noSetup {
            error("Giveaway was in process of being setup, resetting giveaway.")
            reset()
        }
        var dict = [String: Any]()
        dict["setup"] = isSetup
        dict["running"] = isRunning
        dict["giving"] = tobegiven
        dict["draw"] = drawOn
        dict["time"] = time
        dict["id"] = id
        dict["winners"] = numOfWinners
        return dict as NSDictionary
    }
    
    func giveaway(from dict: NSDictionary) {
        isSetup = dict["setup"] as! Bool
        isRunning = dict["running"] as! Bool
        tobegiven = dict["giving"] as! String
        if let draw = dict["draw"] as? Date {
            drawOn = draw
            if draw >= Date() && isRunning {
                error("There is a giveaway needing awarding, please use `giveaway finish`")
            } else if isRunning {
                error("Please restart the giveaway with the command `giveaway finish`")
            }
        }
        if let t = dict["time"] as? TimeInterval {
            time = t
        }
        if let i = dict["id"] as? UInt64 {
            id = i
        }
        numOfWinners = dict["winners"] as! Int
    }
}

func sendDM(msg: Message, embed: Embed, completion: @escaping (Bool) -> Void) {
    bot.getDM(for: msg.author!.id) { (dm, e) in
        if let e = e {
            error("There was an error", error: e.message, inReplyTo: msg)
            completion(false)
        } else if let dm = dm {
            dm.send(embed)
            completion(true)
        } else {
            error("Could not find DM", inReplyTo: msg)
            completion(false)
        }
    }
}
