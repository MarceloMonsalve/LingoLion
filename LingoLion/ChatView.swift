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
    var gptChat: [OpenAI.Chat]
    @Published var chat: [String]
    
    // Initializes the ViewModel and sends the api an initial "Hello"
    init(systemMessage: String) {
        openAI = OpenAI(apiToken: Plist.getStringValue(forKey: "API_KEY"))
        chat = [String]()
        gptChat = [.init(role: "system", content: systemMessage), .init(role: "user", content: "Hello"),]
        Task {
            await self.apiCall() { response in
                self.addMessage(role: "assistant",text: response)
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
        let query = OpenAI.ChatQuery(model: .gpt3_5Turbo, messages: gptChat)
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
        self.addMessage(role: "user",text: text)
        Task {
            await self.apiCall() { response in
                self.addMessage(role: "assistant", text: response)
            }
        }
    }
    
    // Appends given message to chat and gptChat arrays. Deletes duplicate entries from gptChat and in future will be responsible for keeping gptChat under 2500 tokens.
    func addMessage(role: String, text: String) {
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
            self.chat.append("\(self.role(role: role)): \(text)")
        }
        
    }
}

// The View for the main page of the app
struct ChatView: View {
    @ObservedObject var viewModel: ViewModel
    @State var text = ""
//    let topic: String
//    let language: String
//    let systemMessage: String
    
    init(topic: String, language: String) {
//        self.topic = topic
//        self.language = language
        let systemMessage = "You are Lingo Lion a language learning helper that has practice conversations with people learning a new language on various topics. The user says they want to have a conversation about this: \"\(topic)\" in this language: \(language). Act as a character in there senario to have a conversation where you say a sentence and they respond one message at a time. Limit your messages to 80 words or less."
        self.viewModel = ViewModel(systemMessage: systemMessage)
    }
    
    var body: some View {
        VStack {
            Text("Lingo Lion")
                .font(.title)
            
            List(viewModel.chat, id: \.self) { message in
                Text(message)
            }
            Spacer()
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    viewModel.send(text: text)
                    text = ""
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(topic: "Ordering Food", language: "French")
    }
}
