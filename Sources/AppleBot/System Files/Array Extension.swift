//
//  Array Extention.swift
//  AppleBot
//
//  Created by Erik Bean on 2/18/19.
//

import Foundation

extension ArraySlice {
    var array: Array<Element> {
        return Array(self)
    }
}
