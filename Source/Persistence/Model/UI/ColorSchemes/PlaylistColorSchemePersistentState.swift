//
//  PlaylistColorSchemePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates persistent app state for a single PlaylistColorScheme.
 */
struct PlaylistColorSchemePersistentState: Codable {
    
    let trackNameTextColor: ColorPersistentState?
    let groupNameTextColor: ColorPersistentState?
    let indexDurationTextColor: ColorPersistentState?
    
    let trackNameSelectedTextColor: ColorPersistentState?
    let groupNameSelectedTextColor: ColorPersistentState?
    let indexDurationSelectedTextColor: ColorPersistentState?

    let summaryInfoColor: ColorPersistentState?
    
    let playingTrackIconColor: ColorPersistentState?
    let selectionBoxColor: ColorPersistentState?
    let groupIconColor: ColorPersistentState?
    let groupDisclosureTriangleColor: ColorPersistentState?
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = ColorPersistentState(color: scheme.trackNameTextColor)
        self.groupNameTextColor = ColorPersistentState(color: scheme.groupNameTextColor)
        self.indexDurationTextColor = ColorPersistentState(color: scheme.indexDurationTextColor)
        
        self.trackNameSelectedTextColor = ColorPersistentState(color: scheme.trackNameSelectedTextColor)
        self.groupNameSelectedTextColor = ColorPersistentState(color: scheme.groupNameSelectedTextColor)
        self.indexDurationSelectedTextColor = ColorPersistentState(color: scheme.indexDurationSelectedTextColor)
        
        self.groupIconColor = ColorPersistentState(color: scheme.groupIconColor)
        self.groupDisclosureTriangleColor = ColorPersistentState(color: scheme.groupDisclosureTriangleColor)
        self.selectionBoxColor = ColorPersistentState(color: scheme.selectionBoxColor)
        self.playingTrackIconColor = ColorPersistentState(color: scheme.playingTrackIconColor)
        
        self.summaryInfoColor = ColorPersistentState(color: scheme.summaryInfoColor)
    }
}
