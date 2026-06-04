//
//  SimonColor.swift
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
