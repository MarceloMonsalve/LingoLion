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
    @State private var isChatViewActive = false
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
                
                HStack {
                    NavigationLink {
                        ChatView(language: language)
                    } label: {
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
