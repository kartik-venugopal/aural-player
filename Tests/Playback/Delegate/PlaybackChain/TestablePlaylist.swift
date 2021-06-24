//
//  TestablePlaylist.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TestablePlaylist: Playlist {
    
    var getGapBeforeCallCounts: [Track: Int] = [:]
    var getGapAfterCallCounts: [Track: Int] = [:]
    
    var removeGapForTrackCallCounts: [Track: [PlaybackGapPosition: Int]] = [:]
    var removeGapsForTrackCallCounts: [Track: Int] = [:]
    
    var setGapsForTrackCallCounts: [Track: Int] = [:]
    
    override func getGapBeforeTrack(_ track: Track) -> PlaybackGap? {
        
        getGapBeforeCallCounts[track] = (getGapBeforeCallCounts[track] ?? 0) + 1
        return super.getGapBeforeTrack(track)
    }
    
    override func getGapAfterTrack(_ track: Track) -> PlaybackGap? {
        
        getGapAfterCallCounts[track] = (getGapAfterCallCounts[track] ?? 0) + 1
        return super.getGapAfterTrack(track)
    }
    
    override func removeGapForTrack(_ track: Track, _ gapPosition: PlaybackGapPosition) {
        
        if removeGapForTrackCallCounts[track] == nil {
            
            removeGapForTrackCallCounts[track] = [:]
            removeGapForTrackCallCounts[track]![gapPosition] = 0
        }
        
        removeGapForTrackCallCounts[track]![gapPosition] = removeGapForTrackCallCounts[track]![gapPosition]! + 1
        
        super.removeGapForTrack(track, gapPosition)
    }
    
    override func removeGapsForTrack(_ track: Track) {
        
        removeGapsForTrackCallCounts[track] = (removeGapsForTrackCallCounts[track] ?? 0) + 1
        super.removeGapsForTrack(track)
    }
    
    override func setGapsForTrack(_ track: Track, _ gapBeforeTrack: PlaybackGap?, _ gapAfterTrack: PlaybackGap?) {
        
        setGapsForTrackCallCounts[track] = (setGapsForTrackCallCounts[track] ?? 0) + 1
        super.setGapsForTrack(track, gapBeforeTrack, gapAfterTrack)
    }
}
