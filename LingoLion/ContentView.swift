//
//  ContentView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/4/23.
//

import SwiftUI
import OpenAI

let systemMessage = "You are Lingo Lion a language learning helper that has practice conversations with people learning a new language on various topics."
let apikey = "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"

// ViewModel for the main chat with the AI. Keeps track of two chats: one is the one that gets shown to the user and one is the one sent to the api. The api chat must be kept under 2500 tokens (not yet implemented.
class ViewModel: ObservableObject {
    let openAI: OpenAI
    var gptChat: [OpenAI.Chat]
    @Published var chat: [String]
    
    // Initializes the ViewModel and sends the api an initial "Hello"
    init() {
        openAI = OpenAI(apiToken: apikey)
        chat = [String]()
        gptChat = [.init(role: "system", content: systemMessage), .init(role: "user", content: "Hello"),]
        Task {
            await self.apiCall() { response in
                self.addMessage(role: "assistant",text: response)
            }
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
            print("Error code 1738")
            await self.apiCall { string in
                completion(string)
            }
            
        }
    }
    
    // Called when the user presses send. Calls apiCall with new response from user and updates chat and gptChat through addMessage accordingly.
    func send(text: String) {
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
struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    
    var body: some View {
        VStack {
            Text("Lingo Lion")
                .font(.title)
                .fontWeight(.bold)
            
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
        ContentView()
    }
}
