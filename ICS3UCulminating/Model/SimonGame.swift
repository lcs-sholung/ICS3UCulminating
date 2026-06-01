//
//  SimonGame.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

// MARK: - SimonColor
// This enum represents the four different colored buttons in the Simon game.
// We use a String raw value so we can easily display the color name if needed.
// It conforms to CaseIterable so we can easily pick a random color from the list.
enum SimonColor: String, CaseIterable {
    case green = "Green"
    case red = "Red"
    case yellow = "Yellow"
    case blue = "Blue"
}

// MARK: - GameState
// This enum represents the different phases or "states" that the Simon game can be in.
// Using an enum helps us keep track of what the game is currently doing.
enum GameState {
    case waitingToStart    // The game is at the beginning, waiting for the player to press "Start".
    case showingSequence   // The game is currently playing back the sequence for the player to watch.
    case waitingForInput   // The game is waiting for the player to repeat the sequence by pressing buttons.
    case gameOver          // The player pressed the wrong button and the game has ended.
}

// MARK: - SimonGame
// This structure represents the data and state of a single Simon game session.
// In a Model-View-ViewModel (MVVM) architecture, this is the "Model".
// It holds the "truth" about what is happening in the game.
struct SimonGame {
    
    // MARK: - Stored properties
    // These properties store the information that changes as the game progresses.
    
    // The current sequence of colors that the player must memorize and repeat.
    // Every round, we add one more random color to this array.
    var sequence: [SimonColor] = []
    
    // The sequence of colors the player has pressed so far in the current round.
    // This is reset to an empty array at the start of every new round.
    var playerInput: [SimonColor] = []
    
    // The current phase of the game. We start in the 'waitingToStart' state.
    var state: GameState = .waitingToStart
    
    // The player's current score.
    // In Simon, the score is usually the number of colors in the longest sequence successfully repeated.
    var score: Int = 0
    
    // MARK: - Computed properties
    // These properties do not store data themselves, but calculate a value based on stored properties.
    
    // This property checks if the player has finished entering all the colors for the current round.
    var isRoundComplete: Bool {
        // A round is complete if the player has pressed as many buttons as there are in the sequence.
        // We only care about this if the game is currently waiting for the player's input.
        if state == .waitingForInput {
            return playerInput.count == sequence.count
        } else {
            return false
        }
    }
    
    // MARK: - Initializer
    // Initializers get a new instance of the structure ready for use.
    
    init() {
        // By default, a new game starts with empty lists and a zero score.
        self.sequence = []
        self.playerInput = []
        self.state = .waitingToStart
        self.score = 0
    }
    
    // MARK: - Functions
    // These functions allow us to modify the state of the game in a controlled way.
    
    // This function adds a new random color to the end of the current sequence.
    mutating func addRandomColor() {
        // .randomElement() picks one item from the list of all colors (green, red, yellow, blue).
        if let randomColor = SimonColor.allCases.randomElement() {
            sequence.append(randomColor)
        }
    }
}
