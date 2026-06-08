//
//  SimonButton.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// MARK: - SimonButton
// A helper view that represents a single color button in the Simon game.
// It changes its appearance based on whether it is "highlighted" by the ViewModel.
struct SimonButton: View {
    
    // The color this button represents.
    let color: SimonColor
    
    // The ViewModel that this button will interact with.
    var viewModel: SimonViewModel
    
    // MARK: - Computed properties
    
    // Determines the background color for the button based on the SimonColor enum.
    var swiftUIColor: Color {
        switch color {
        case .green: return .green
        case .red: return .red
        case .yellow: return .yellow
        case .blue: return .blue
        }
    }
    
    // Determines if this specific button is currently "lit up" by the game.
    var isHighlighted: Bool {
        return viewModel.highlightedColor == color
    }
    
    // The 'body' property defines the visual appearance and interaction for the button.
    var body: some View {
        Button(action: {
            // When the button is pressed, tell the ViewModel to handle the input.
            viewModel.handleInput(for: color)
        }) {
            // The visual representation of the button.
            // We use the first letter of the color name as the label.
            Text(String(color.rawValue.prefix(1)))
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 120, height: 120)
                .background(swiftUIColor)
                .cornerRadius(20)
                // If the button is NOT highlighted, we dim it slightly (opacity 0.4).
                // If it IS highlighted, it glows with full opacity (1.0).
                .opacity(isHighlighted ? 1.0 : 0.4)
                // We add a subtle shadow when highlighted to make it "pop".
                .shadow(color: isHighlighted ? swiftUIColor : Color.clear, radius: 10)
        }
        // Disable the button animation when it's just being lit up by the game sequence,
        // so it doesn't look like a "press" when it's just flashing.
        .buttonStyle(PlainButtonStyle())
    }
}
