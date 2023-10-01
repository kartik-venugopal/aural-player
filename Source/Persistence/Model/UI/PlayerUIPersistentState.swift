//
//  PlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Player UI.
///
/// - SeeAlso: `PlayerUIState`
///
struct PlayerUIPersistentState: Codable {
    
    let viewType: PlayerViewType?
    let controlsViewType: PlayerControlsViewType?
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    let showTrackInfo: Bool?
    
    let showPlayingTrackFunctions: Bool?
    let showControls: Bool?
    let showTimeElapsedRemaining: Bool?
    
    let timeElapsedDisplayType: TimeElapsedDisplayType?
    let timeRemainingDisplayType: TimeRemainingDisplayType?
}
