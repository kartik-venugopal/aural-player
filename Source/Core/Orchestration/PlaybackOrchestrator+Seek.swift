//
// PlaybackOrchestrator+Seek.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlaybackOrchestrator {
    
    func seekBackward() -> PlaybackCommandResult {
        currentStateAsCommandResult
    }
    
    func seekBackwardSecondary() -> PlaybackCommandResult {
        currentStateAsCommandResult
    }
    
    func seekForward() -> PlaybackCommandResult {
        currentStateAsCommandResult
    }
    
    func seekForwardSecondary() -> PlaybackCommandResult {
        currentStateAsCommandResult
    }
}
