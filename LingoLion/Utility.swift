//
//  Utility.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 5/7/23.
//

import Foundation
import SwiftUI

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

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

func convertToBCP47Code(language: String) -> String {
    switch language.lowercased() {
    case "english":
        return "en-US"
    case "spanish":
        return "es-ES"
    case "french":
        return "fr-FR"
    case "german":
        return "de-DE"
    case "italian":
        return "it-IT"
    case "portuguese":
        return "pt-BR"
    case "chinese":
        return "zh-CN"
    case "japanese":
        return "ja-JP"
    case "korean":
        return "ko-KR"
    case "russian":
        return "ru-RU"
    case "arabic":
        return "ar-SA"
    case "dutch":
        return "nl-NL"
    case "swedish":
        return "sv-SE"
    case "norwegian":
        return "no-NO"
    case "danish":
        return "da-DK"
    case "finnish":
        return "fi-FI"
    case "polish":
        return "pl-PL"
    case "turkish":
        return "tr-TR"
    case "greek":
        return "el-GR"
    case "hindi":
        return "hi-IN"
    default:
        return "NO BCP47 CODE FOUND"
    }
}
