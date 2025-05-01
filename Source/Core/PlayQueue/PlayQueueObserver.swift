//
// PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

protocol PlayQueueObserver {
    
    var id: String {get}
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams)
    
    func addedTracks(at trackIndices: IndexSet)
    
    func doneAddingTracks(urls: [URL])
}
