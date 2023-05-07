//
//  Utility.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 5/7/23.
//

import Foundation

struct Plist {
    static func getStringValue(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let value = dict[key] as? String else {
            fatalError("Could not find value for key \(key) in MyPlist.plist")
        }
        return value
    }
}
