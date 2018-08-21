//
//  StrikeManager.swift
//  AppleBot
//
//  Created by Erik Bean on 8/12/18.
//

import Foundation
import Sword

/*
 *                   Wookiee 5 Step
 *
 * _________________________________________________________
 *
 * Infractions
 *
 * When a user commits an infraction, it is handled in one
 * of three ways. A strike (described below), a ban, or a
 * warning. Each are distint, but are not interchangable.
 *
 * _________________________________________________________
 *
 * Warnings
 *
 * A warning is the least harmful of all three types. They
 * send a DM to a user with a friendly warning message that
 * a valid user with permission has set to send. This is not
 * logged in the srike log, but IS logged in the bot daily
 * log, as well as in any room where the bot is set to print
 * moderation logs.
 *
 * _________________________________________________________
 *
 * Strikes
 *
 * Apple Bot will work off a FIVE stike system, with the
 * SIXTH stike rolling over into a ban. This means that a
 * user can aquire 5 stikes, and will be banned if they get
 * one more.
 *
 * _________________________________________________________
 *
 * Bans
 *
 * Banning works like any other bans on Discord.
 *
 * _________________________________________________________
 *
 * Global Bans
 *
 * The Global Ban system is a system designed to help
 * prevent another mass character spam incident. This list
 * represents a list of accounts banned on one guild that
 * should be insta-banned on entry of any Apple Discord.
 *
 * This will also be retro-active, automaticly banning them
 * if they are in any of the approved guilds already,
 * preventing the need for additional bans/ work.
 *
 * _________________________________________________________
 *
 * Un-banning
 *
 * Unbanning a user is not like traditional bots (or like
 * RowBoat for the most part). When a user is banned, their
 * infractions stay listed in the strike logs for future
 * queue WHILE they are banned. As soon as a user is
 * UN-BANNED, their infractions are cleared from the strike
 * log.
 *
 * WARNING: This will clear the users current strikes
 *
 * This is done for multiple reasons, but in the end this
 * means that you will NOT be able to search past strikes.
 * This will be a second, third, forth.... nth chance for
 * the user. So unban wisely!
 */

class StrikeManager {
    static let main = StrikeManager()
    private init() { }
    
    #warning("STRIKE NOT FINISHED")
    func strike(_ strike: Strike) {
        if strike.mute {
            mute(strike)
        }
        // TODO: Finish me
    }
    
    func ban(_ strike: String) {
        /// TODO: Implement guild ban
        /// TODO: Force Ban system
    }
    
    func warning(_ strike: Strike) {
        /// TODO: Get strike message and relay it to the offender in DM
    }
    
    private func mute(_ strike: Strike) {
        muteExist(strike: strike) { (muted, err) in
            if let err = err {
                error("Strike Manager Error", error: "Seams there was an error... \(err.localizedDescription)")
                ABLogger.log(action: "STRIKE_MNGR: Mute Error: Seams there was an error... \(err.localizedDescription)")
            } else if let muted = muted {
                let members = strike.guild.members
                for member in members {
                    if member.key == strike.offender.id {
                        let mem = member.value
                        var rawRoles = [muted.id.rawValue]
                        for role in mem.roles {
                            rawRoles.append(role.id.rawValue)
                        }
                        strike.guild.modifyMember(member.key, with: ["roles": rawRoles], then: { (err) in
                            if let err = err {
                                error("Strike Manager Error", error: "Seams there was an error... \(err.localizedDescription)")
                                ABLogger.log(action: "STRIKE_MNGR: Mute Error: Seams there was an error... \(err.localizedDescription)")
                            }
                        })
                    }
                }
            } else {
                self.createMuted(strike: strike, completion: { (muted, err) in
                    if let err = err {
                        error("Strike Manager Error", error: "Seams there was an error... \(err.localizedDescription)")
                        ABLogger.log(action: "STRIKE_MNGR: Mute Error: Seams there was an error... \(err.localizedDescription)")
                    } else if let muted = muted {
                        let members = strike.guild.members
                        for member in members {
                            if member.key == strike.offender.id {
                                let mem = member.value
                                var rawRoles = [muted.id.rawValue]
                                for role in mem.roles {
                                    rawRoles.append(role.id.rawValue)
                                }
                                strike.guild.modifyMember(member.key, with: ["roles": rawRoles], then: { (err) in
                                    if let err = err {
                                        error("Strike Manager Error", error: "Seams there was an error... \(err.localizedDescription)")
                                        ABLogger.log(action: "STRIKE_MNGR: Mute Error: Seams there was an error... \(err.localizedDescription)")
                                    }
                                })
                            }
                        }
                    } else {
                        error("Strike Manager Error", error: "Seams there was an error... And unknown error has occured, no error was generated, but the role does not exist!")
                        ABLogger.log(action: "STRIKE_MNGR: Unknown Error (did you get a meatball stuck in the damn thing again?)")
                    }
                })
            }
        }
    }
    
    private func write(_ strike: Strike) {
        // TODO: Finish Me
    }
    
    private func read(userID id: UInt64, guild: UInt64 = 0) -> String? {
        #if os(macOS)
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        #else
        var path = Bundle.main.executablePath!
        #endif
        // TODO: Finish Me
        return String()
    }
}

struct Strike {
    let offender: User!
    let accuser: UInt64!
    let guild: Guild!
    let reason: String? = nil
    let mute: Bool = false
    let experation: Date? = nil
}
