//
//  PlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct PlayerUIPersistentState: Codable {
    
    let viewType: PlayerViewType?
    
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

extension PlayerViewState {
    
    static func initialize(_ persistentState: PlayerUIPersistentState?) {
        
        viewType = persistentState?.viewType ?? PlayerViewDefaults.viewType
        
        showAlbumArt = persistentState?.showAlbumArt ?? PlayerViewDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? PlayerViewDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? PlayerViewDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? PlayerViewDefaults.showCurrentChapter
        
        showTrackInfo = persistentState?.showTrackInfo ?? PlayerViewDefaults.showTrackInfo
        
        showPlayingTrackFunctions = persistentState?.showPlayingTrackFunctions ?? PlayerViewDefaults.showPlayingTrackFunctions
        showControls = persistentState?.showControls ?? PlayerViewDefaults.showControls
        showTimeElapsedRemaining = persistentState?.showTimeElapsedRemaining ?? PlayerViewDefaults.showTimeElapsedRemaining
        
        timeElapsedDisplayType = persistentState?.timeElapsedDisplayType ?? PlayerViewDefaults.timeElapsedDisplayType
        timeRemainingDisplayType = persistentState?.timeRemainingDisplayType ?? PlayerViewDefaults.timeRemainingDisplayType
    }
    
    static var persistentState: PlayerUIPersistentState {
        
        PlayerUIPersistentState(viewType: viewType,
            showAlbumArt: showAlbumArt,
            showArtist: showArtist,
            showAlbum: showAlbum,
            showCurrentChapter: showCurrentChapter,
            showTrackInfo: showTrackInfo,
            showPlayingTrackFunctions: showPlayingTrackFunctions,
            showControls: showControls,
            showTimeElapsedRemaining: showTimeElapsedRemaining,
            timeElapsedDisplayType: timeElapsedDisplayType,
            timeRemainingDisplayType: timeRemainingDisplayType)
    }
}
