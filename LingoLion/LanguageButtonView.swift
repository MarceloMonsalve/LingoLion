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
                    .bold()
                Image(systemName: "chevron.down")
            }
            .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.wood)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.woodShadow, lineWidth: 3)
                            )
                    )
        }
        .popover(isPresented: $showingLanguageList, content: {
            List(languages, id: \.self) { language in
                Button(action: {
                    self.language = language
                    self.showingLanguageList = false
                }) {
                    Text(language)
                        .bold()
                }
            }
        })
        .foregroundColor(.darkWood)
        
    }
}


struct LanguageButtonView_Previews: PreviewProvider {
    @State static var language = "French"
    static var previews: some View {
        LanguageButtonView(language: $language)
    }
}
