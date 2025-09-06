//
//  ContentView.swift
//  WordScramble
//
//  Created by Sanguo Joseph Ledoux on 9/3/25.
//

import SwiftUI

struct ContentView: View {
    class PlayerScore: Identifiable {
        var name: String
        var score: Int

        init(name: String, score: Int) {
            self.name = name
            self.score = score
        }
    }

    @State private var usedWords: [String] = []
    @State private var playerHistory: [PlayerScore] = [
        PlayerScore(name: "ledoux", score: 25)
    ]
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var userName = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingRestart = false
    @State private var showResult = false
    @State private var score = 0
    @State private var highScore = 25
    @State private var wordCount = 0

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
        newWord = ""
    }

    func startGame() {
        if let startWordUrl = Bundle.main.url(
            forResource: "start",
            withExtension: "txt"
        ) {
            if let startWords = try? String(contentsOf: startWordUrl) {
                let allWords = startWords.components(separatedBy: "\n")

                rootWord = allWords.randomElement() ?? "silkworm"

                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }

    func addNewWord() {
        let word = newWord.lowercased().trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard word.count > 0 else { return }

        guard isOriginal(word) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word) else {
            wordError(
                title: "Word not possible",
                message: "You can't spell that word from '\(rootWord)'!"
            )
            return
        }

        guard isReal(word) else {
            wordError(
                title: "Word not recognized",
                message: "You can;t just make them up you know!"
            )
            return
        }

        guard isNotObvoius(word) else {
            wordError(
                title: "It's not that obivous",
                message: "Your answer is obviously (in) the root word"
            )
            return
        }

        withAnimation {
            usedWords.insert(word, at: 0)
            score += word.count
            highScore = score > highScore ? score : highScore
        }

        newWord = ""
    }

    func isOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(_ word: String) -> Bool {
        var copy = rootWord

        for letter in word {
            if let pos = copy.firstIndex(of: letter) {
                copy.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    func isReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )

        return mispelledRange.location == NSNotFound
    }

    func isNotObvoius(_ word: String) -> Bool {
        !rootWord.contains(word)
    }

    var body: some View {
        NavigationStack {

            List {

                TextField("Enter your word", text: $newWord)
                    .textInputAutocapitalization(.never)

                Section("\(5-wordCount) words left") {
                    Section {
                        HStack(alignment: .center) {
                            Spacer()
                            VStack {
                                Text("score : \(score)", ).font(.title)
                                Text("highest score : \(highScore)", )
                                    .foregroundStyle(Color.gray).font(.caption)
                            }
                            Spacer()
                        }
                    }
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle.fill")
                                Text(word)
                            }
                        }
                    }

                }
            }
            .toolbar {
                if !(wordCount >= 5) {
                    Button("Next Word") {
                        startGame()
                        wordCount += 1
                        newWord = ""
                        showResult = wordCount == 5
                    }

                }

                Button("Restart", role: .destructive) {
                    showingRestart = true
                }
                .foregroundStyle(.red)
                .alert(
                    "Do you really want to restart ?",
                    isPresented: $showingRestart
                ) {

                    Button("Restart", role: .destructive) {
                        startGame()
                        wordCount = 0
                        score = 0
                    }
                } message: {
                    Text("Your Progression will be lost")
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert("Enter your player ID", isPresented: $showResult) {
                TextField("########", text: $userName)
                Button("save") {

                    for (index, player) in playerHistory.enumerated() {
                        if score >= player.score {
                            withAnimation {
                                playerHistory.insert(
                                    PlayerScore.init(
                                        name: userName,
                                        score: score
                                    ),
                                    at: index
                                )
                            }
                            break
                        }
                       
                        if index + 1  == playerHistory.count {
                            withAnimation{
                                playerHistory.append(
                                    PlayerScore.init(
                                        name: userName,
                                        score: score
                                    )
                                )
                            }
                            
                        }

                    }
                    startGame()
                    wordCount = 0
                    score = 0

                }
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") {
                    showingError = false
                }
            } message: {
                Text(errorMessage)
            }

            List {

                Section("Leader board") {
                    ForEach(playerHistory) { player in
                        HStack {
                            Text(player.name.prefix(1).uppercased())
                                .frame(width: 40, height: 40)
                                .background(.black)
                                .clipShape(.circle)
                                .foregroundStyle(.white)
                            Text(player.name.capitalized)
                            Spacer()
                            Text("\(player.score) points")

                        }
                    }

                }
            }

        }
    }
}

#Preview {
    ContentView()
}
