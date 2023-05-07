//
//  ContentView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/21/23.
//

import SwiftUI

struct ContentView: View {
    @State private var topic = ""
    @State private var language = "French"
    var body: some View {
        VStack {
            ZStack {
//                HStack {
//                    Spacer()
//                    Button(action: {
//
//                    }, label: {
//                        Image(systemName: "line.3.horizontal")
//                            .foregroundColor(.black)
//                            .imageScale(.large)
//                    })
//                    .padding()
//                }
                Text("Lingo Lion").font(.title)
            }
            .padding()
            Spacer()
            TextField("What topic do you want to practice?",
                      text: $topic,
                      onCommit: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
            .lineLimit(3, reservesSpace: true)
            .textFieldStyle(.roundedBorder)
            .padding()
            
            HStack {
                NavigationLink(destination: ChatView(topic: topic, language: language)) {
                    HStack {
                        Text("Start")
                    }
                    .padding()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                )
                LanguageButtonView(language: $language)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                    )
            }
            .padding(.horizontal)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
