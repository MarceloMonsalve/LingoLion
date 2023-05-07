//
//  LanguageButtonView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/22/23.
//

import SwiftUI

struct LanguageButtonView: View {
    @State private var showingLanguageList = false
    @Binding var language: String

    let languages = [
        "Spanish",
        "French",
        "German",
        "Italian",
        "Japanese"
        // Add more languages as needed
    ]

    var body: some View {
        Button(action: {
            self.showingLanguageList.toggle()
        }) {
            HStack {
                Text("\(language)")
                Image(systemName: "chevron.down")
            }
        }
        .popover(isPresented: $showingLanguageList, content: {
            List(languages, id: \.self) { language in
                Button(action: {
                    self.language = language
                    self.showingLanguageList = false
                }) {
                    Text(language)
                }
            }
        })
    }
}


struct LanguageButtonView_Previews: PreviewProvider {
    @State static var language = "French"
    static var previews: some View {
        LanguageButtonView(language: $language)
    }
}
