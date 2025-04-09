//
// AudioGraph+VolumeAndPan.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension AudioGraph {
    
    var volume: Float {
        
        get {engine.volume}
        set {engine.volume = newValue}
    }
    
    func increaseVolume(by increment: Float) -> Float {
        engine.increaseVolume(by: increment)
    }
    
    func decreaseVolume(by decrement: Float) -> Float {
        engine.decreaseVolume(by: decrement)
    }
    
    var pan: Float {
        
        get {engine.pan}
        set {engine.pan = newValue}
    }
    
    func panLeft(by delta: Float) -> Float {
        engine.panLeft(by: delta)
    }
    
    func panRight(by delta: Float) -> Float {
        engine.panRight(by: delta)
    }
    
    var muted: Bool {
        
        get {engine.muted}
        set {engine.muted = newValue}
    }
}
