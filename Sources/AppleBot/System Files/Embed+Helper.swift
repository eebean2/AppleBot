//
//  Embed+Helper.swift
//  AppleBot
//
//  Created by Erik Bean on 5/7/18.
//

import Sword

enum ABColor: Int {
    case testing = 0x00FFFF     // Cyan
    case system = 0x000000      // Black
    case apple = 0xFFFFFF       // White
    case alert = 0xCC0000       // Red
    
    var intColor: Int {
        return self.rawValue
    }
}

class EmbedReply {
    var embed = Embed()
    
    func reply(to: Message, title: String, message: String?, color: ABColor) {
        embed.title = title
        embed.description = message
        embed.color = color.intColor
        to.reply(with: embed)
    }
    
    // TODO: Custom Error Title
    
    func error(on: Message, error: String?) {
        embed.title = "Error"
        embed.description = error
        embed.color = ABColor.alert.intColor
        on.reply(with: embed)
    }
    
    func invalidPermission(on: Message) {
        embed.title = "Oops!"
        embed.description = "You do not have permission to use this command."
        embed.color = ABColor.alert.intColor
        on.reply(with: embed)
    }
    
    static func getEmbed(withTitle title: String, message: String?, color: ABColor) -> Embed {
        var e = Embed()
        e.title = title
        e.description = message
        e.color = color.intColor
        return e
    }
    
}
