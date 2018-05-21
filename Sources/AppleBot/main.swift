import Sword
import Foundation

let bot = Sword(token: botToken)

botStartup()

bot.on(Event.guildIntegrationsUpdate) { data in
    print("GUILD INTERACTIONS UPDATE FOLLOWING\n")
    print(data as! Guild)
}

bot.on(Event.guildCreate) { data in
    print("GUILD CREATE FOLLOWING\n")
    print(data as! Guild)
}

bot.on(Event.guildUpdate) { data in
    let gld = data as! Guild
    print("GUILD UPDATE FOLLOWING\n")
    print(gld)
    print("\nGUILD MEMBERS FOLLOWING\n")
    print(gld.members)
}

bot.on(Event.guildDelete) { data in
    print("GUILD DELETE FOLOWING\n")
    print(data as! Guild)
}

bot.on(.messageCreate) { data in
    let msg = data as! Message
    if roleSetup != .noSetup && msg.channel.type == .dm && Giveaway.manager.setupUser?.id.rawValue == msg.author?.id.rawValue {
        
        if roleSetup == .giveawayNeedsItem || roleSetup == .giveawayNeedsDate {
            Giveaway.manager.setup(msg: msg)
        } else {
            error("Unknown Setup Found", error: "Setup was at \(roleSetup). Setup defaulting to non-setup state, please check Xcode", inReplyTo: msg)
            Giveaway.manager.reset()
        }
        
    } else if let command = Parser.getCommand(msg: msg) {
        CommandCenter().commandCheck(command, msg: msg)
    }
}

bot.on(.reactionAdd) { data in
    let (channel, userID, messageID, emoji) = data as! (TextChannel, Snowflake, Snowflake, Emoji) // TexhChannel, UserID, MessageID, Emoji
    print("Channel: \(channel)")
    print("UserID: \(userID)")
    print("MessageID: \(messageID)")
    print("Emoji: \(emoji)")
}

bot.connect()
