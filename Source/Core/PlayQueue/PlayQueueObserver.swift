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
    
    // Lower number = higher priority
    var observerPriority: Int {get}
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams)
    
    func addedTracks(_ tracks: [Track], at trackIndices: IndexSet, params: PlayQueueTrackLoadParams)
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams)
}

protocol PlayQueueUIObserver {
    
    var id: String {get}
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void)
    
    func addedTracks(_ tracks: [Track], at trackIndices: IndexSet, params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void)
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void)
}
