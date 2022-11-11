//
//  MockPlayerGraph.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class MockPlayerGraph: PlayerGraphProtocol {
    
    var playerNode: AuralPlayerNode = MockPlayerNode(useLegacyAPI: false, volume: 1, pan: 0)
    
    var reconnectedPlayerNodeWithFormat: Bool = false
    var playerConnectionFormat: AVAudioFormat? = nil
    
    func reconnectPlayerNode(withFormat format: AVAudioFormat) {
        
        reconnectedPlayerNodeWithFormat = true
        playerConnectionFormat = format
    }
    
    func clearSoundTails() {
    }
}
