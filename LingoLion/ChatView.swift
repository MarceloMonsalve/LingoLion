//
//  ChatView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/4/23.
//

import SwiftUI
import OpenAI
import SwiftfulLoadingIndicators



// ViewModel for the main chat with the AI. Keeps track of two chats: one is the one that gets shown to the user and one is the one sent to the api. The api chat must be kept under 2500 tokens (not yet implemented.
class ViewModel: ObservableObject {
    let language: String
    let textToSpeech: TextToSpeech
    let openAI: OpenAI
    var gptChat: [Chat]
    @Published var chat: [String]
    @Published var thinking: Bool
    
    // Initializes the ViewModel and sends the api an initial "Hello"
    init(systemMessage: String, language: String) {
        self.thinking = false
        self.textToSpeech = TextToSpeech()
        self.language = language
        self.openAI = OpenAI(apiToken: Plist.getStringValue(forKey: "API_KEY"))
        self.chat = [String]()
        self.gptChat = [.init(role: .system, content: systemMessage)]
    }
    
    func init2() {
        Task { @MainActor in
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
                self.thinking = false
                completion(string)
            }
        }
    }
    
    // Called when the user presses send. Calls apiCall with new response from user and updates chat and gptChat through addMessage accordingly.
    func send(text: String) {
        if text.count > 500 {
            let message = "That message was too long, try saying something shorter."
            Task { @MainActor in
                self.chat.append(message)
                return
            }
            
        }
        self.addMessage(role: .user,text: text)
        self.thinking = true
        Task { @MainActor in
            self.thinking = true
            await self.apiCall() { response in
                self.addMessage(role: .assistant, text: response)
            }
            self.thinking = false
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
        Task { @MainActor in
            self.chat.append("\(self.role(role: role.rawValue)): \(text)")
        }
        
        if (role == .assistant) {
            self.textToSpeech.speak(text: text, language: self.language)
        }
        
    }
}

// The View for the main page of the app
struct ChatView: View {
    @ObservedObject var viewModel: ViewModel
    @State var text = ""
    
    init(language: String) {
        let systemMessage = "You are Lingo Lion a \(language) language tutor that teaches by practicing conversation with the student. When given a topic or conversation, play the role of a character in that topic in a dialogue with the student. Respond to the student one message at a time (Do NOT send the student a whole conversatin in one message) keeping your messages consise and 80 words or less. Speak only in in \(language) and do not provide english translations (unless asked for by the student). Start with hello and asking what they want to practice (one sentence) in \(language)."
        
        self.viewModel = ViewModel(systemMessage: systemMessage, language: language)
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
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack() {
                            ForEach(viewModel.chat.indices, id: \.self) { i in
                                Text(viewModel.chat[i])
                                    .id(i)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            HStack {
                                if (viewModel.thinking || viewModel.chat.isEmpty) {
                                    Text("Lingo Lion: ")
                                        .padding(8)
                                    LoadingIndicator(animation: .threeBallsBouncing, color: Color.darkWood, size: .small)
                                }
                                Spacer()
                            }
                            .id("bottom")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                            
                        }
                        .onChange(of: viewModel.thinking) { value in proxy.scrollTo("bottom", anchor: nil)}
                    }
                    .frame(maxHeight: 500)
                    .padding()
                    .padding(.top, 35)
                }
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
                .background(Color.wood)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.woodShadow, lineWidth: 3)
                )
                .padding()
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            Image("Lion")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .position(x: 300,y:20)
        }
        .onAppear {
            viewModel.init2()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(language: "French")
    }
}
