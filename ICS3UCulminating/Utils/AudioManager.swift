//
//  AudioManager.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-08.
//

import Foundation
import AVFoundation

// MARK: - AudioManager
// This class is responsible for playing musical notes associated with each button.
// It uses AVAudioEngine to generate simple sine wave tones for a clear, "musical" feel.
class AudioManager {
    
    // MARK: - Stored properties
    
    // The shared instance allows us to access the AudioManager from anywhere in the app.
    static let shared = AudioManager()
    
    // The audio engine handles the actual sound generation and output.
    private let audioEngine = AVAudioEngine()
    
    // The player node is where we schedule our sound "packets" to be played.
    private let playerNode = AVAudioPlayerNode()
    
    // We define a standard mono audio format (44.1kHz) to use throughout the class.
    // This ensures consistency between the engine connection and the buffers we create.
    private let monoFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
    
    // MARK: - Initializer
    
    private init() {
        // We don't start the engine here anymore. 
        // We will start it only when a sound is actually played to avoid issues in Previews.
    }
    
    // MARK: - Functions
    
    // Ensures the audio engine is set up and running.
    private func ensureEngineIsRunning() -> Bool {
        // If the engine is already running, we are good to go.
        if audioEngine.isRunning {
            return true
        }
        
        // Check if we are running in a SwiftUI Preview.
        // Audio engine can sometimes crash in the preview environment, so we might want to skip it.
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return false
        }
        
        do {
            // 1. Attach the player node if it hasn't been attached yet.
            if playerNode.engine == nil {
                audioEngine.attach(playerNode)
                
                // 2. Connect the player node to the engine's output.
                // IMPORTANT: We use our specific 'monoFormat' here. This tells the engine
                // to expect mono input from the player and handle the conversion to
                // stereo output for the speakers automatically.
                audioEngine.connect(playerNode, to: audioEngine.outputNode, format: monoFormat)
            }
            
            // 3. Start the engine.
            try audioEngine.start()
            return true
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
            return false
        }
    }
    
    // Plays a specific musical note for a given SimonColor.
    // Each color is mapped to a different frequency (musical pitch).
    func playNote(for color: SimonColor) {
        // First, make sure the engine is running.
        guard ensureEngineIsRunning() else { return }
        
        // Map colors to frequencies (Standard "Simon" notes or similar)
        // Green: 415 Hz (G#4)
        // Red: 310 Hz (Eb4)
        // Yellow: 252 Hz (B3)
        // Blue: 209 Hz (Ab3)
        let frequency: Double
        switch color {
        case .green: frequency = 415.30
        case .red: frequency = 311.13
        case .yellow: frequency = 246.94
        case .blue: frequency = 207.65
        }
        
        // Generate and play the tone.
        playTone(frequency: frequency, duration: 0.4)
    }
    
    // A helper function that generates a simple sine wave tone.
    private func playTone(frequency: Double, duration: Double) {
        // 1. Calculate the number of samples needed for the given duration.
        // We use the sample rate defined in our 'monoFormat'.
        let sampleRate = monoFormat.sampleRate
        let frameCount = UInt32(duration * sampleRate)
        
        // 2. Create an audio buffer to hold the sound data using our consistent 'monoFormat'.
        guard let buffer = AVAudioPCMBuffer(pcmFormat: monoFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        // 3. Fill the buffer with a sine wave at the desired frequency.
        let channels = buffer.floatChannelData!
        let channel = channels[0]
        for i in 0..<Int(frameCount) {
            // Sine wave formula: amplitude * sin(2 * pi * frequency * time)
            // We use a small amplitude (0.2) so it's not too loud.
            channel[i] = Float(0.2 * sin(2.0 * Double.pi * frequency * Double(i) / sampleRate))
            
            // Apply a simple "fade out" at the end to prevent clicking sounds.
            let fadeOutStart = Int(Double(frameCount) * 0.8)
            if i > fadeOutStart {
                let fadePercentage = 1.0 - Double(i - fadeOutStart) / Double(Int(frameCount) - fadeOutStart)
                channel[i] *= Float(fadePercentage)
            }
        }
        
        // 5. Schedule the buffer to play on the player node.
        // We tell it to play immediately.
        playerNode.play()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    }
}
