//
// SoundOrchestratorProtocol.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

protocol SoundOrchestratorProtocol {
    
    var volume: Float {get set}
    var displayedVolume: String {get}
    func increaseVolume(inputMode: UserInputMode)
    func decreaseVolume(inputMode: UserInputMode)
    
    var pan: Float {get set}
    var displayedPan: String {get}
    func panLeft()
    func panRight()
    
    var muted: Bool {get set}
    func toggleMuted()
    
    func registerUI(ui: SoundUI)
    
    func deregisterUI(ui: SoundUI)
    
    // Shuts down the audio graph, releasing all its resources
    func tearDown()
}

extension SoundOrchestratorProtocol {
    
    func increaseVolume() {
        increaseVolume(inputMode: .discrete)
    }
    
    func decreaseVolume() {
        decreaseVolume(inputMode: .discrete)
    }
}

struct SoundUnits {
    
    // Multiply by these numbers
    
    static let volumeFactor: Float = 1.0/100
    static let uiVolumeFactor: Float = 100
    static let volumeRange: ClosedRange<Float> = 0...1
    
    static let panFactor: Float = 1.0/100
    static let uiPanFactor: Float = 100
    static let panRange: ClosedRange<Float> = -1...1
}

protocol SoundUI {
    
    var id: String {get}
    
    func volumeChanged(newVolume: Float, displayedVolume: String, muted: Bool)
    func panChanged(newPan: Float, displayedPan: String)
    func mutedChanged(newMuted: Bool, volume: Float, displayedVolume: String)
}

extension SoundUI {

    func volumeChanged(newVolume: Float, displayedVolume: String, muted: Bool) {}
    func panChanged(newPan: Float, displayedPan: String) {}
    func mutedChanged(newMuted: Bool, volume: Float, displayedVolume: String) {}
}
