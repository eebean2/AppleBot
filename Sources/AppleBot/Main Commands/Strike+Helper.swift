//
//  Strike+Helper.swift
//  AppleBot
//
//  Created by Erik Bean on 8/20/18.
//

import Foundation
import Sword

extension StrikeManager {
    
    internal func muteExist(strike: Strike, completion: @escaping (Role?, RequestError?) -> Void) {
        strike.guild.getRoles(then: { (roles, requestError) in
            if let err = requestError {
                completion(nil, err)
            } else if let roles = roles {
                for role in roles {
                    if role.name == "Muted" {
                        completion(role, nil)
                    }
                }
                completion(nil, nil)
            } else {
                completion(nil, nil)
            }
        })
    }
    
    internal func createMuted(strike: Strike, completion: @escaping (Role?, RequestError?) -> Void) {
        let muted: [String: Any] = [
            "name": "Muted",
            "permissions": 0,
            "color": 0x808080,
            "hoist": false,
            "mentionable": false
        ]
        strike.guild.createRole(with: muted, then: { (role, error) in
            if error == nil {
                ABLogger.log(action: "STRIKE_MNG: We now have the ability to shut people up. Someone should have thought of this earlier to be honest...")
            }
            completion(role, error)
        })
    }
    
    @discardableResult
    func fileCheck(guild: UInt64 = 0) -> Bool {
        var guildName:String = "\(guild)"
        #if os(macOS)
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        #else
        let path = Bundle.main.executablePath!
        #endif
        var file = path
        if guild == 0 {
            guildName = "master"
            file.append("/AppleBot/StrikeManager/master.txt")
        } else {
            file.append("/AppleBot/StrikeManager/\(guild).txt")
        }
        if FileManager.default.fileExists(atPath: file) {
            ABLogger.log(action: "STRIKE_MNGR_NOTICE: Infraction table found for " + guildName + " guild")
            return true
        } else {
            ABLogger.log(action: "STRIKE_MNGR_ERROR: File NOT found for " + guildName + " guild")
            return false
        }
    }
}
