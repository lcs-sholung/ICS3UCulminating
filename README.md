# Simon Sequence Recall Game

A classic electronic memory game built with SwiftUI following the MVVM (Model-View-ViewModel) architectural pattern.

## Overview

The Simon game tests a player's ability to recall and repeat an increasingly complex sequence of lights and sounds. This implementation uses a 2x2 grid of colored buttons and tracks the player's score and recent high scores.

## Features

- **Sequence Generation:** The game adds a random color to the sequence each round.
- **Visual Feedback:** Buttons "light up" (increase opacity and add glow) to show the sequence and player input.
- **High Score Tracking:** Displays the three most recent best scores achieved in the current session.
- **State Management:** Uses an explicit `GameState` enum to manage transitions between starting, watching, playing, and game over.

## Technical Details

- **Language:** Swift 6.0
- **Framework:** SwiftUI
- **Architecture:** MVVM
  - **Model:** `SimonGame`, `SimonColor`, `GameState`
  - **ViewModel:** `SimonViewModel` (using the `@Observable` macro)
  - **View:** `SimonView`, `SimonButton`
- **Concurrency:** Uses Swift Concurrency (`Task` and `await`) for non-blocking timing during sequence playback.

## How to Play

1. Press **Start Game**.
2. Watch the sequence of colors as they light up.
3. Repeat the sequence by tapping the buttons in the same order.
4. Each successful round adds one more color to the sequence.
5. If you tap the wrong color, the game ends.
