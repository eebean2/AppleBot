//
//  InfractionManager.swift
//  AppleBot
//
//  Created by Erik Bean on 8/12/18.
//

import Foundation
import Sword

class InfractionManager {
    static let main = InfractionManager()
    private init() { }
    
    func issueInfraction(_ command: Command, inf: Infraction) {
        if command == .tempmute {
            tempmute(inf)
        } else {
            ABLogger.log(action: "Infraction Manager Error: A command (\(command.string)) was issued to INFM, but INFM is not capable of executing it.")
            error("Infraction Manager was issued command \(command.string), but the infraction manager is not capable of executing it.")
            return
        }
    }
    
    private func tempmute(_ inf: Infraction) {
        if let guild = inf.guild {
            
        } else {
            if let message = inf.msg {
                error("Oh no!", error: "We could not apply this mute because the guild information is missing", inReplyTo: message)
            } else {
                error("Oh no!", error: "We could not apply this mute because the guild information is missing")
            }
        }
    }
    
    // Infraction Format for Reading and Writing
    //
    // -------------------------------------
    // | INFN | Float  | Infraction Number |
    // | OFFN | UInt64 | Offender          |
    // | TYPE | String | Infraction Type   |
    // | ACCU | UInt64 | Accuser           |
    // | OCUR | Date   | Infraction Date   |
    // | EXPD | Date   | Experation Date   |
    // | REAS | String | Reason            |
    // | MESG | UInt64 | Message           |
    // | GILD | UInt64 | Guild             |
    // -------------------------------------
    private func write(_ inf: String) {
        
    }
    
    private func read() -> String {
        
        return String()
    }
}
