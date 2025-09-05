//
//  ContentView.swift
//  WordScramble
//
//  Created by Sanguo Joseph Ledoux on 9/3/25.
//

import SwiftUI


 

struct ContentView: View {
    @State private var usedWords : [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError  = false
    
    func wordError(title : String, message : String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func startGame(){
        if let startWordUrl =  Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordUrl){
                let allWords = startWords.components(separatedBy: "\n")
                
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    func addNewWord(){
        let word = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard word.count > 0 else {return}
        
        guard isOriginal(word) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word) else {
            wordError(title: "Word not recognized", message: "You can;t just make them up you know!") 
            return
        }
        
        withAnimation {
            usedWords.insert(word, at: 0)
        }
        
        
        newWord = ""
    }
    
    
    func isOriginal(_ word : String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(_ word : String) -> Bool{
     var copy = rootWord
        
        for letter in word{
            if let pos = copy.firstIndex(of: letter){
                copy.remove(at: pos)
            }else{
                return false
            }
        }
        
        return true
    }
    
    func isReal(_ word : String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        
        return mispelledRange.location == NSNotFound
    }

    var body: some View {
        NavigationStack{
            List(){
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError ){
                Button("OK"){
                    showingError = false
                }
            } message : {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}
