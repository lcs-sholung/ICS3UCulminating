//
//  SimonViewModel.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation
import SwiftUI

// MARK: - SimonViewModel
// This class is the "ViewModel" for our Simon game.
// It acts as a bridge between the Model (SimonGame) and the View.
// It handles the logic of the game, like showing the sequence with timing
// and checking if the player pressed the right buttons.
@Observable
class SimonViewModel {
    
    // MARK: - Stored properties
    
    // This is our source of truth, the game data itself.
    // We mark it as 'private(set)' so that the View can read the game state
    // but only this ViewModel can change it.
    private(set) var game: SimonGame = SimonGame()
    
    // This array stores the three most recent "best scores" (scores from completed games).
    // We keep it limited to the top 3 and sort them from highest to lowest.
    private(set) var recentBestScores: [Int] = []
    
    // This property keeps track of which color is currently "lit up" or "active".
    // When the game is showing the sequence, we will set this to a color, wait a bit,
    // then set it back to nil. The View will use this to change the button's appearance.
    var highlightedColor: SimonColor? = nil
    
    // This property stores the state of the game BEFORE it was paused.
    // This allows us to return to the correct phase (showing sequence or waiting for input) when unpausing.
    private var stateBeforePause: GameState = .waitingToStart
    
    // MARK: - Initializer
    
    init() {
        // We start with a fresh game instance.
        self.game = SimonGame()
        
        // We load any previously saved scores from the device's storage.
        loadScores()
    }
    
    // MARK: - Functions
    
    // Starts a brand new game.
    func startGame() {
        // 1. Reset the game state to fresh values.
        game = SimonGame()
        
        // 2. Add the first random color to the sequence.
        game.addRandomColor()
        
        // 3. Begin showing the sequence to the player.
        // We use a Task because showing the sequence involves waiting (pauses),
        // which must happen "asynchronously" so the app doesn't freeze.
        Task {
            await showSequence()
        }
    }
    
    // Plays back the current sequence for the player to memorize.
    func showSequence() async {
        // Update the game state so the View knows we are currently showing the sequence.
        game.state = .showingSequence
        
        // Before we start, clear any previous player input.
        game.playerInput = []
        
        // Wait a short moment before starting the sequence so the player is ready.
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Iterate through every color in the current sequence.
        for color in game.sequence {
            
            // CHECK FOR PAUSE:
            // If the player pauses the game while the sequence is playing,
            // we need to "wait" here until they unpause.
            while game.state == .paused {
                // We sleep for a tiny amount (0.1 seconds) and then check again.
                // This prevents the app from "looping" too fast and using up battery.
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            
            // If the player quit while we were paused or waiting, stop the sequence entirely.
            if game.state == .waitingToStart {
                return
            }
            
            // \"Light up\" the current color.
            highlightedColor = color
            
            // Play the musical note associated with this color.
            AudioManager.shared.playNote(for: color)
            
            // Wait for the player to see the light (e.g., 0.6 seconds).
            try? await Task.sleep(nanoseconds: 600_000_000)
            
            // Turn off the light.
            highlightedColor = nil
            
            // Wait a tiny bit between colors so they don't blend together (e.g., 0.2 seconds).
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        
        // Once the sequence is finished, wait for the player to start pressing buttons.
        game.state = .waitingForInput
    }
    
    // This function is called every time the player taps a color button.
    func handleInput(for color: SimonColor) {
        // If the game isn't currently waiting for input, ignore the tap.
        // (This prevents the player from "cheating" while the sequence is playing or if paused).
        guard game.state == .waitingForInput else {
            return
        }
        
        // 1. Add the color the player just pressed to their input list.
        game.playerInput.append(color)
        
        // Play the musical note for the button the player just pressed.
        AudioManager.shared.playNote(for: color)
        
        // 2. Check if the button they just pressed is the CORRECT one.
        // We compare the color they just pressed to the color at the same position in the original sequence.
        let currentIndex = game.playerInput.count - 1
        let correctColor = game.sequence[currentIndex]
        
        if color == correctColor {
            // If it's correct, check if they've finished the whole sequence for this round.
            if game.isRoundComplete {
                // They got them all right!
                // Increase the score.
                game.score += 1
                
                // Move to the next round after a brief pause.
                Task {
                    // Wait 1 second so the player can celebrate their success.
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    
                    // Add a new color to make the next round harder.
                    game.addRandomColor()
                    
                    // Show the new, longer sequence.
                    await showSequence()
                }
            }
        } else {
            // If they pressed the wrong button, the game is over.
            game.state = .gameOver
            
            // When the game ends, record the score in our best scores list.
            updateBestScores(with: game.score)
        }
    }
    
    // Pauses the current game.
    func pauseGame() {
        // Only allow pausing if the game is currently active.
        if game.state == .showingSequence || game.state == .waitingForInput {
            // Remember where we were so we can come back.
            stateBeforePause = game.state
            game.state = .paused
        }
    }
    
    // Resumes the game from where it was paused.
    func unpauseGame() {
        if game.state == .paused {
            game.state = stateBeforePause
        }
    }
    
    // Quits the current game and returns to the start screen.
    func quitGame() {
        game.state = .waitingToStart
        game = SimonGame() // Reset the game data
    }
    
    // Updates the list of the three most recent best scores.
    private func updateBestScores(with newScore: Int) {
        // 1. Add the new score to our list.
        recentBestScores.append(newScore)
        
        // 2. Sort the scores in descending order (highest to lowest).
        // We use a simple loop-based sort to keep it clear for students.
        recentBestScores.sort { $0 > $1 }
        
        // 3. If we have more than 3 scores, keep only the top 3.
        if recentBestScores.count > 3 {
            recentBestScores.removeLast()
        }
        
        // 4. Save the updated list to the device's storage.
        saveScores()
    }
    
    // MARK: - Persistence Functions
    
    // Saves the top scores to a JSON file on the device.
    private func saveScores() {
        // 1. Convert our array of integers into JSON data.
        if let encodedData = try? JSONEncoder().encode(recentBestScores) {
            // 2. Save that data into the 'UserDefaults' storage (a simple persistent database).
            UserDefaults.standard.set(encodedData, forKey: "recentBestScores")
        }
    }
    
    // Loads the top scores from the device's storage when the app starts.
    private func loadScores() {
        // 1. Look for the saved data in 'UserDefaults'.
        if let savedData = UserDefaults.standard.data(forKey: "recentBestScores") {
            // 2. If we find it, try to convert the JSON data back into an array of integers.
            if let decodedScores = try? JSONDecoder().decode([Int].self, from: savedData) {
                // 3. Update our property with the loaded scores.
                self.recentBestScores = decodedScores
            }
        }
    }
}
