//
//  SimonView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// MARK: - SimonView
// This is the "View" layer of our app.
// It is responsible for displaying the game state to the user and
// capturing their interactions (like button taps).
struct SimonView: View {
    
    // MARK: - Stored properties
    
    // We create an instance of our ViewModel using @State.
    // This tells SwiftUI to "watch" this object for any changes
    // and redraw the view whenever something inside it changes.
    @State private var viewModel: SimonViewModel = SimonViewModel()
    
    // MARK: - Computed properties
    
    // The 'body' property defines the layout and appearance of the view.
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: Header Section
            // Displays the current score and the status of the game.
            VStack {
                Text("Simon Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Score: \(viewModel.game.score)")
                    .font(.title2)
            }
            
            // MARK: Game Board Section
            // A 2x2 grid representing the four colored buttons.
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    // Green Button
                    SimonButton(color: .green, viewModel: viewModel)
                    
                    // Red Button
                    SimonButton(color: .red, viewModel: viewModel)
                }
                
                HStack(spacing: 20) {
                    // Yellow Button
                    SimonButton(color: .yellow, viewModel: viewModel)
                    
                    // Blue Button
                    SimonButton(color: .blue, viewModel: viewModel)
                }
            }
            
            // MARK: Controls Section
            // Shows different buttons or messages depending on the game's state.
            if viewModel.game.state == .waitingToStart {
                Button(action: {
                    // Tell the ViewModel to start the game when this button is pressed.
                    viewModel.startGame()
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
            } else if viewModel.game.state == .gameOver {
                VStack {
                    Text("GAME OVER")
                        .font(.title)
                        .foregroundColor(.red)
                        .fontWeight(.heavy)
                    
                    Button(action: {
                        // Reset the game and start again.
                        viewModel.startGame()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
            } else if viewModel.game.state == .showingSequence {
                Text("Watch the sequence...")
                    .font(.headline)
                    .italic()
            } else if viewModel.game.state == .waitingForInput {
                Text("Your turn!")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding()
    }
}

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

// MARK: - Preview
#Preview {
    SimonView()
}
