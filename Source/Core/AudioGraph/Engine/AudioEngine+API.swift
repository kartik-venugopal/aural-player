//
// AudioEngine+API.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AVFoundation

extension AudioEngine {
    
    private static let volumeRange: ClosedRange<Float> = 0...1
    private static let panRange: ClosedRange<Float> = -1...1
    
    var volume: Float {
        
        get {playerNode.volume}
        set {playerNode.volume = newValue.clamped(to: Self.volumeRange)}
    }
    
    func increaseVolume(by increment: Float) -> Float {
        
        volume += increment
        return volume
    }
    
    func decreaseVolume(by decrement: Float) -> Float {
        
        volume -= decrement
        return volume
    }
    
    var pan: Float {
        
        get {playerNode.pan}
        set {playerNode.pan = newValue.clamped(to: Self.panRange)}
    }
    
    func panLeft(by delta: Float) -> Float {
        
        pan -= delta
        return pan
    }
    
    func panRight(by delta: Float) -> Float {
        
        pan += delta
        return pan
    }
    
    var muted: Bool {
        
        get {auxMixer.muted}
        set {auxMixer.muted = newValue}
    }
    
    func insertNode(_ node: AVAudioNode) {
        
        guard let lastNode = allNodes.last else {return}
        
        engine.disconnectNodeOutput(lastNode)
        
        removableNodes.append(node)
        engine.attach(node)
        
        engine.connect(lastNode, to: node, format: nil)
        engine.connect(node, to: mainMixerNode, format: nil)
    }
    
    // Assume indices are valid and sorted in descending order.
    // NOTE - Indices are relative to the number of audio units, not actual node indices.
    func removeNodes(at descendingIndices: [Int]) {
        
        for index in descendingIndices {
        
            var previousNode: AVAudioNode = permanentNodes.last!
            var nextNode: AVAudioNode = engine.mainMixerNode
            
            // Find the node previous to the node to be removed.
            if index > 0 {
                
                for previousIndex in stride(from: index - 1, to: -1, by: -1) {
                    
                    if !descendingIndices.contains(previousIndex) {
                        
                        previousNode = removableNodes[previousIndex]
                        break
                    }
                }
            }
            
            // Find the node next to the node to be removed.
            if index < removableNodes.lastIndex {
                
                for nextIndex in (index + 1)...removableNodes.lastIndex {
                    
                    if !descendingIndices.contains(nextIndex) {
                        
                        nextNode = removableNodes[nextIndex]
                        break
                    }
                }
            }
            
            // Sever the connections with the node to be removed.
            engine.disconnectNodeOutput(previousNode)
            engine.disconnectNodeInput(nextNode)
            
            // Connect the previous / next node together.
            engine.connect(previousNode, to: nextNode, format: nil)
        }
        
        for index in descendingIndices {
            engine.detach(removableNodes.remove(at: index))
        }
    }
    
    var playerOutputFormat: AVAudioFormat {
        playerNode.outputFormat(forBus: 0)
    }
    
    func reconnectPlayerNode(withFormat format: AVAudioFormat) {
        
        if playerOutputFormat != format {
            
            engine.disconnectNodeOutput(playerNode)
            engine.connect(playerNode, to: auxMixer, format: format)
        }
    }
    
    func clearSoundTails() {
        
        // Clear sound tails from reverb and delay nodes, if they're active
        if delayUnit.isActive {delayUnit.reset()}
        if reverbUnit.isActive {reverbUnit.reset()}
    }
    
    func start() {
        
        do {
            try engine.start()
        } catch let error as NSError {
            NSLog("Error starting audio engine: %@", error.description)
        }
    }
    
    func stop() {
        engine.stop()
    }
}
