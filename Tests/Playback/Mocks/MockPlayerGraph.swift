//
//  MockPlayerGraph.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class MockPlayerGraph: PlayerGraphProtocol {
    
    var playerNode: AuralPlayerNode = MockPlayerNode(useLegacyAPI: false)
    
    var reconnectedPlayerNodeWithFormat: Bool = false
    var playerConnectionFormat: AVAudioFormat? = nil
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        
        reconnectedPlayerNodeWithFormat = true
        playerConnectionFormat = format
    }
    
    func clearSoundTails() {
    }
    
    var audioEngineRestarted: Bool = false
    
    func restartAudioEngine() {
        audioEngineRestarted = true
    }
}
