//
//  AudioEngine.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Encapsulates an **AVAudioEngine** and provides convenient audio engine lifecycle functions.
/// It also provides functions to add or remove audio processing nodes and manage their connections
/// to each other.
///
class AudioEngine {
    
    private let engine: AVAudioEngine
    
    private var permanentNodes: [AVAudioNode] = []
    private var removableNodes: [AVAudioNode] = []
    
    private var allNodes: [AVAudioNode] {
        permanentNodes + removableNodes
    }
    
    private(set) lazy var outputNode: AVAudioOutputNode = engine.outputNode
    private(set) lazy var mainMixerNode: AVAudioMixerNode = engine.mainMixerNode
    
    init() {
        self.engine = AVAudioEngine()
    }
    
    // Connects all nodes in sequence.
    func addNodes(permanentNodes: [AVAudioNode], removableNodes: [AVAudioNode]) {
        
        self.permanentNodes = permanentNodes
        self.removableNodes = removableNodes
        
        let allNodes = self.allNodes
        
        // Attach and connect the nodes, forming a chain.
        
        allNodes.forEach {engine.attach($0)}
        
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
        engine.connect(allNodes.last!, to: mainMixerNode, format: nil)
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
    
    // Reconnects two nodes with the given audio format (required when a track change occurs)
    func reconnect(outputOf node1: AVAudioNode, toInputOf node2: AVAudioNode, withFormat format: AVAudioFormat) {
        
        engine.disconnectNodeOutput(node1)
        engine.connect(node1, to: node2, format: format)
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
