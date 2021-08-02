//
//  UIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all persistent state for the application UI.
///
struct UIPersistentState: Codable {
    
    let appMode: AppMode?
    let windowLayout: WindowLayoutsPersistentState?
    let themes: ThemesPersistentState?
    let fontSchemes: FontSchemesPersistentState?
    let colorSchemes: ColorSchemesPersistentState?
    let player: PlayerUIPersistentState?
    let playlist: PlaylistUIPersistentState?
    let visualizer: VisualizerUIPersistentState?
    let windowAppearance: WindowAppearancePersistentState?
    
    let menuBarPlayer: MenuBarPlayerUIPersistentState?
    let controlBarPlayer: ControlBarPlayerUIPersistentState?
}
