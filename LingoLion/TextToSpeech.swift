//
//  TextToSpeech.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 5/16/23.
//

import Foundation
import AVFoundation

class TextToSpeech {
    let synthesizer: AVSpeechSynthesizer
    init() {
        synthesizer = AVSpeechSynthesizer()
    }
    
    func speak(text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: convertToBCP47Code(language: language))
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)  
    }
}
