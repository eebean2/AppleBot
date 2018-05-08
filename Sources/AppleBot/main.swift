import Sword
import Foundation

let bot = Sword(token: botToken)

bot.send(EmbedReply.getEmbed(withTitle: "Apple Bot is Now Starting", message: nil, color: .system), to: Snowflake(rawValue: testChannel))
bot.editStatus(to: "online", playing: "with the!")

Parser().readData(msg: nil)

bot.on(Event.guildIntegrationsUpdate) { data in
    print("GUILD INTERACTIONS UPDATE FOLLOWING\n")
    print(data as! Guild)
}

bot.on(Event.guildCreate) { data in
    print("GUILD CREATE FOLLOWING\n")
    print(data as! Guild)
}

bot.on(Event.guildUpdate) { data in
    print("GUILD UPDATE FOLLOWING\n")
    print(data as! Guild)
    
    let gld = data as! Guild
    print("\nGUILD MEMBERS FOLLOWING\n")
    print(gld.members)
}

bot.on(Event.guildDelete) { data in
    print("GUILD DELETE FOLOWING\n")
    print(data as! Guild)
}

bot.on(.messageCreate) { data in
    let msg = data as! Message
    
    CommandCenter().commandCheck(msg)
    
    if msg.content.contains("\(indicator)kick") {
        print(msg.content)
        print(msg.mentions)
        print(msg.content.count)
        var r: Int = 29
        if msg.content.count > r {
            let reason = msg.content
        }
    }
    
    if msg.content.contains("\(indicator)approved") {
        let check = Parser.serverCheck(ID: Parser.getGuildID(msg: msg))
        if check {
            msg.reply(with: "You are approved to use Apple Bot!")
        } else {
            msg.reply(with: "iTunes has stopped working. Just kidding, but really... you can't use me on here... Sorry!")
        }
    }
}

bot.connect()
