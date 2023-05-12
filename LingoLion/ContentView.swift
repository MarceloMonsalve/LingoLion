//
//  ContentView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/21/23.
//

import SwiftUI

struct ContentView: View {
//    @State private var topic = ""
    @State private var language = "French"
    var body: some View {
        
        ZStack {
            Color.sky
                .ignoresSafeArea()
            VStack {
                Circle()
                    .foregroundColor(.sun)
                    .frame(width: 150, height: 150)
                    .position(x: 10, y:10)
                Spacer()
                Image("Grass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .ignoresSafeArea()
            
            VStack(alignment: .center) {
                Image("LingoLion")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
//                TextField("What topic do you want to practice?",
//                          text: $topic,
//                          onCommit: {
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                })
//                .lineLimit(3, reservesSpace: true)
//                .textFieldStyle(.roundedBorder)
//                .padding()
                
                HStack {
                    NavigationLink(destination: ChatView(language: language)) {
                        Image("Start")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            
                    }
                    
                    LanguageButtonView(language: $language)
                        .padding()
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
