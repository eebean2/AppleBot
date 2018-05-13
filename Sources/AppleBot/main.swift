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
    if Parser.getCommand(msg: msg) != nil {
        CommandCenter().commandCheck(Parser.getCommand(msg: msg)!, msg: msg)
    }
}

bot.connect()
