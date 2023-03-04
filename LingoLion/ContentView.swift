//
//  ContentView.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 3/4/23.
//

import SwiftUI
import OpenAI



class ViewModel: ObservableObject {
    let openAI: OpenAI
    @Published var messages: [String]
    
    init() {
        openAI = OpenAI(apiToken: "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")
        messages = [String]()
    }
    
    func send(question: String,
              completion: @escaping (String) -> Void) async {
        let query = OpenAI.ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: "user", content: question)])
        do {
            let result = try await self.openAI.chats(query: query)
            completion((result.choices.first?.message.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            print("Error code 1738")
        }
    }
    
    func addMessage(text: String) {
        self.messages.append(text)
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    
    var body: some View {
        VStack {
            Text("Lingo Lion")
                .font(.title)
                            .fontWeight(.bold)
            List(viewModel.messages, id: \.self) { string in
                Text(string)
            }
            Spacer()
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    ButtonSend()
                }
            }
            .padding()
        }
    }
    
    func ButtonSend() {
        viewModel.addMessage(text: "Me: \(text)")
        Task{
            await viewModel.send(question: text) { response in
                DispatchQueue.main.async {
                    viewModel.addMessage(text: "ChatGPT: \(response)")
                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
