//
//  ChatView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/4/23.
//

import SwiftUI
import OpenAI



// ViewModel for the main chat with the AI. Keeps track of two chats: one is the one that gets shown to the user and one is the one sent to the api. The api chat must be kept under 2500 tokens (not yet implemented.
class ViewModel: ObservableObject {
    let openAI: OpenAI
    var gptChat: [Chat]
    @Published var chat: [String]
    
    // Initializes the ViewModel and sends the api an initial "Hello"
    init(systemMessage: String) {
        openAI = OpenAI(apiToken: Plist.getStringValue(forKey: "API_KEY"))
        chat = [String]()
        gptChat = [.init(role: .system, content: systemMessage), .init(role: .user, content: "Hello. Ask me what I want to practice talking about today."),]
        Task {
            await self.apiCall() { response in
                self.addMessage(role: .assistant,text: response)
            }
        }
    }
    
    // Shortens the array of messages to an acceptable length
    func shorten() {
        var numChar = 0
        for chat in gptChat {
            numChar = numChar + chat.content.count
        }
        while numChar > 4000 {
            numChar = numChar - gptChat[2].content.count
            gptChat.remove(at: 2)
        }
    }
    
    // Helper function to change the role to how it will be displayed
    func role(role: String) -> String {
        switch role {
        case "assistant": return "Lingo Lion"
        case "user": return "You"
        default: return role
        }
    }
    
    // Sends gptChat array to the api and if theres an error then it calls it recursively until it works. Sends a string with the chatgpt's response to the completion.
    func apiCall(completion: @escaping (String) -> Void) async {
        let query = ChatQuery(model: .gpt3_5Turbo, messages: gptChat)
        do {
            let result = try await self.openAI.chats(query: query)
            completion((result.choices.first?.message.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            print("Error: \(error)")
            await self.apiCall { string in
                completion(string)
            }
            
        }
    }
    
    // Called when the user presses send. Calls apiCall with new response from user and updates chat and gptChat through addMessage accordingly.
    func send(text: String) {
        if text.count > 500 {
            self.chat.append("That message was too long, try saying something shorter.")
            return
        }
        self.addMessage(role: .user,text: text)
        Task {
            await self.apiCall() { response in
                self.addMessage(role: .assistant, text: response)
            }
        }
    }
    
    // Appends given message to chat and gptChat arrays. Deletes duplicate entries from gptChat and in future will be responsible for keeping gptChat under 2500 tokens.
    func addMessage(role: Chat.Role, text: String) {
        var i = 0
        for message in self.gptChat {
            if message.content == text && message.role == role {
                self.gptChat.remove(at: i)
                break
            }
            i += 1
        }
        self.gptChat.append(.init(role: role, content: text))
        DispatchQueue.main.async {
            self.chat.append("\(self.role(role: role.rawValue)): \(text)")
        }
        
    }
}

// The View for the main page of the app
struct ChatView: View {
    @ObservedObject var viewModel: ViewModel
    @State var text = ""
    
    init(language: String) {
//        self.topic = topic
//        self.language = language
//        let systemMessage1 = "You are Lingo Lion, a language tutor that acts as a character in a dialogue with the user. Right now the user wants to practice \"\(topic)\" in \(language). For example: if they want to practice getting directions you will play the local and they will play tourist. Have a dialogue where you say a sentence and they respond one message at a time. Limit your messages to 80 words or less."
        
        let systemMessage = "You are Lingo Lion a \(language) language tutor that teaches by practicing conversation with the student. When given a topic, play the role of a character in a dialogue with the user. Respond to the user one message at a time keeping your messages concise and 80 words or less. Speak only in in \(language) and do not provide english translations unless asked for by the student."
        
        self.viewModel = ViewModel(systemMessage: systemMessage)
    }
    
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
            VStack {
                List(viewModel.chat, id: \.self) { message in
                    Text(message)
                }
                .listStyle(PlainListStyle())
                .cornerRadius(10)
                .padding()
                .padding(.top, 35)
                
                Spacer()
                
                HStack {
                    TextField("Type here...", text: $text)
                        .accentColor(.darkWood)
                    Button("Send") {
                        viewModel.send(text: text)
                        text = ""
                    }
                    
                }
                .foregroundColor(.darkWood)
                .padding()
            }
            
            Image("Lion")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .position(x: 300,y:20)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(language: "French")
    }
}
