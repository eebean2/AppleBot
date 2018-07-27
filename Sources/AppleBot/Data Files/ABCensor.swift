//
//  ABCensor.swift
//  AppleBot
//
//  Created by Erik Bean on 7/27/18.
//

import Foundation

class ABCensor {
    
    static func wordCheck(phrase: String) -> Bool {
        print(phrase)
        if phrase.isEmpty || phrase.isNull || phrase == "" { return false }
        do {
            if let p = Bundle.main.path(forResource: "ABBanWordList", ofType: "txt") {
                let s = try String(contentsOfFile: p)
                let c = s.components(separatedBy: "\n")
                var failed = false
                for i in c {
                    failed = phrase.range(of: "\\b\(i)\\b", options: .regularExpression) != nil
                }
                return failed
            } else {
                print("Bundle path empty")
                return false
            }
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
}
