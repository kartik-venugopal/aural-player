//
//  MockAudioEngine.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

class MockAudioEngine: AudioEngine {
    
    override func addNodes(permanentNodes: [AVAudioNode], removableNodes: [AVAudioNode]) {}
    
    override func insertNode(_ node: AVAudioNode) {}
    
    override func removeNodes(at descendingIndices: [Int]) {}
    
    override func reconnect(outputOf node1: AVAudioNode, toInputOf node2: AVAudioNode, withFormat format: AVAudioFormat) {}
    
    override func start() {}
    
    override func stop() {}
}
