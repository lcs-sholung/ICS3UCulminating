//
//  GameState.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

// MARK: - GameState
// This enum represents the different phases or "states" that the Simon game can be in.
// Using an enum helps us keep track of what the game is currently doing.
enum GameState {
    case waitingToStart    // The game is at the beginning, waiting for the player to press "Start".
    case showingSequence   // The game is currently playing back the sequence for the player to watch.
    case waitingForInput   // The game is waiting for the player to repeat the sequence by pressing buttons.
    case paused            // The game has been temporarily stopped by the player.
    case gameOver          // The player pressed the wrong button and the game has ended.
}
