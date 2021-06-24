//
//  AudioEngine.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

/*
    Encapsulates an AVAudioEngine and provides convenient audio engine lifecycle functions.
*/
class AudioEngine {
    
    private let engine: AVAudioEngine
    
    private var permanentNodes: [AVAudioNode] = []
    private var removableNodes: [AVAudioNode] = []
    private var allNodes: [AVAudioNode] = []
    
    private(set) lazy var outputNode: AVAudioOutputNode = engine.outputNode
    private(set) lazy var mainMixerNode: AVAudioMixerNode = engine.mainMixerNode
    
    init() {
        self.engine = AVAudioEngine()
    }
    
    // Connects all nodes in sequence
    func connectNodes(permanentNodes: [AVAudioNode], removableNodes: [AVAudioNode]) {
        
        addNodes(permanentNodes: permanentNodes, removableNodes: removableNodes)
        connectNodes()
    }
    
    private func addNodes(permanentNodes: [AVAudioNode], removableNodes: [AVAudioNode]) {
        
        allNodes = permanentNodes + removableNodes
        allNodes.forEach {engine.attach($0)}
    }
    
    private func connectNodes() {
        
        var input: AVAudioNode, output: AVAudioNode
        
        // At least 2 nodes required for this to work
        if allNodes.count >= 2 {
            
            for i in 0...allNodes.count - 2 {
                
                input = allNodes[i]
                output = allNodes[i + 1]
                
                engine.connect(input, to: output, format: nil)
            }
        }
        
        // Connect last node to main mixer
        engine.connect(allNodes.last!, to: engine.mainMixerNode, format: nil)
    }
    
    func insertNode(_ node: AVAudioNode) {
        
        let allNodes = permanentNodes + removableNodes
        
        if let lastNode = allNodes.last {
            
            engine.disconnectNodeOutput(lastNode)
            
            removableNodes.append(node)
            self.allNodes = permanentNodes + removableNodes
            
            engine.attach(node)
            
            engine.connect(lastNode, to: node, format: nil)
            engine.connect(node, to: engine.mainMixerNode, format: nil)
        }
    }
    
    // Assume indices are valid and sorted in descending order.
    // NOTE - Indices are relative to the number of audio units, not actual node indices.
    func removeNodes(_ descendingIndices: [Int]) {
        
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
        
        self.allNodes = permanentNodes + removableNodes
    }
    
    // Reconnects two nodes with the given audio format (required when a track change occurs)
    func reconnectNodes(_ inputNode: AVAudioNode, outputNode: AVAudioNode, format: AVAudioFormat) {
        
        engine.disconnectNodeOutput(inputNode)
        engine.connect(inputNode, to: outputNode, format: format)
    }
    
    func start() {
        
        do {
            try engine.start()
        } catch let error as NSError {
            NSLog("Error starting audio engine: %@", error.description)
        }
    }
    
    // TODO: AudioGraph should also respond to this notification and set its _outputDevice var to the new device
    func restart() {
        
        // Disconnect and detach nodes (in this order)
        allNodes.forEach {
            
            engine.disconnectNodeOutput($0)
            engine.disconnectNodeInput($0)
            engine.detach($0)
        }
        
        // Attach them back and reconnect them
        allNodes.forEach {engine.attach($0)}
        connectNodes()
        start()
    }
    
    func stop() {
        engine.stop()
    }
}
