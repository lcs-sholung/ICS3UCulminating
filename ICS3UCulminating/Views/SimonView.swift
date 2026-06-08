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
    
    // This property controls whether the pause menu (confirmation dialog) is currently showing.
    // We use a dedicated state variable here to ensure the pop-up triggers reliably on a single press.
    @State private var isShowingPauseMenu: Bool = false
    
    // MARK: - Computed properties
    
    // The 'body' property defines the layout and appearance of the view.
    var body: some View {
        // We use a ZStack to layer elements on top of each other.
        // In this case, we place the pause button in front of the main game content.
        ZStack(alignment: .topLeading) {
            
            // MARK: Pause Button
            // This button is placed in the top-left corner of the screen.
            // It only appears if the game is currently active (showing sequence or waiting for input) or paused.
            if viewModel.game.state == .showingSequence || viewModel.game.state == .waitingForInput || viewModel.game.state == .paused {
                Button(action: {
                    // 1. Tell the ViewModel to pause the game logic.
                    viewModel.pauseGame()
                    
                    // 2. Trigger the pop-up menu to appear immediately.
                    isShowingPauseMenu = true
                }) {
                    Image(systemName: viewModel.game.state == .paused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 20)
                .padding(.top, 10)
                // We use a confirmation dialog (pop-up) when the game is paused.
                .confirmationDialog("Game Paused", isPresented: $isShowingPauseMenu, titleVisibility: .visible) {
                    Button("Unpause") {
                        viewModel.unpauseGame()
                    }
                    
                    Button("Quit Game", role: .destructive) {
                        viewModel.quitGame()
                    }
                    
                    Button("Cancel", role: .cancel) {
                        // Just closes the menu, remains paused
                    }
                }
            }

            // The main vertical container for the game's title, board, and controls.
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
                    // Top row: Green and Red
                    HStack(spacing: 20) {
                        // Green Button
                        SimonButton(color: .green, viewModel: viewModel)
                        
                        // Red Button
                        SimonButton(color: .red, viewModel: viewModel)
                    }
                    
                    // Bottom row: Yellow and Blue
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
                
                // MARK: Recent Best Scores Section
                // This section displays the history of the player's top 3 performances.
                if !viewModel.recentBestScores.isEmpty {
                    VStack(spacing: 5) {
                        Text("Recent Best Scores")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 15) {
                            ForEach(viewModel.recentBestScores, id: \.self) { score in
                                Text("\(score)")
                                    .font(.headline)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

// MARK: - Preview
// This code allows us to see a live preview of our SimonView inside Xcode.
#Preview {
    SimonView()
}
