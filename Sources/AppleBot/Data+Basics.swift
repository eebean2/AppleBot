//
//  Data+Basics.swift
//  AppleBot
//
//  Created by Erik Bean on 5/3/18.
//

// Super Friends :D = 406145333916205076

import Sword
import Foundation

let botToken: String = "NDM0MTU5NTU4MzExNTQyNzg0.DcvaGQ._jZ8rmuerkYJPiwsRPKwoTVo22k"
let approvedServers: [UInt64] = [406145333916205076, 332309672486895637, 337792272693461002]
let indicator: [UInt64: String] = [406145333916205076: "*"]
let creator: UInt64 = 204675713813446656
var commandPerms: [UInt64: [[String: [UInt64]]]] = [406145333916205076:[[Command.uptime.string: [406159775815172108]]]]
var isSaving = false
var botChannel: [UInt64: UInt64] = [406145333916205076: 441783256699109386]
var testChannel: UInt64 = 441783256699109386



enum Command: String {
    case test = "test"
    case uptime = "uptime"
    case limitCommand = "limitcommand"
    
    var string: String { return toString() }
    
    private func toString() -> String {
        return self.rawValue
    }
}
