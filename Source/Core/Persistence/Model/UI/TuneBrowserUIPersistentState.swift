//
//  TuneBrowserUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Tune Browser.
///
/// - SeeAlso: `TuneBrowserUIState`
///
struct TuneBrowserUIPersistentState: Codable {
    
    let displayedColumns: [TuneBrowserTableColumnPersistentState]?
    let sortColumn: String?
    let sortIsAscending: Bool?
    let sidebar: TuneBrowserSidebarPersistentState?
}

///
/// Persistent state for a single table column displayed within the Tune Browser.
///
/// - SeeAlso: `TuneBrowserTableColumn`
///
struct TuneBrowserTableColumnPersistentState: Codable {
    
    let id: String?
    let width: CGFloat?
}

///
/// Persistent state for the Tune Browser's sidebar.
///
/// - SeeAlso: `TuneBrowserState`
///
struct TuneBrowserSidebarPersistentState: Codable {
    
    let userFolders: [TuneBrowserSidebarItemPersistentState]?
}

///
/// Persistent state for a single item (folder shortcut) displayed the Tune Browser's sidebar.
///
/// - SeeAlso: `TuneBrowserState`
///
struct TuneBrowserSidebarItemPersistentState: Codable {
    
    let folderURL: URL?
    let treeURL: URL?
}
