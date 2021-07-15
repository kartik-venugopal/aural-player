//
//  TuneBrowserPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Tune Browser.
///
/// - SeeAlso: `TuneBrowserState`
///
struct TuneBrowserPersistentState: Codable {
    
    let windowSize: NSSizePersistentState?
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
    let width: CGFloat?
}

///
/// Persistent state for a single item (folder shortcut) displayed the Tune Browser's sidebar.
///
/// - SeeAlso: `TuneBrowserState`
///
struct TuneBrowserSidebarItemPersistentState: Codable {
    
    let url: URLPath?
}

extension TuneBrowserState {
    
    static func initialize(_ persistentState: TuneBrowserPersistentState?) {
        
        windowSize = persistentState?.windowSize?.toNSSize() ?? defaultWindowSize
        displayedColumns = persistentState?.displayedColumns?.compactMap {TuneBrowserTableColumn(persistentState: $0)} ?? []
        sortColumn = persistentState?.sortColumn ?? defaultSortColumn
        sortIsAscending = persistentState?.sortIsAscending ?? defaultSortIsAscending
        
        sidebarWidth = persistentState?.sidebar?.width ?? defaultSidebarWidth
        
        for path in (persistentState?.sidebar?.userFolders ?? []).compactMap({$0.url}) {
            addUserFolder(forURL: URL(fileURLWithPath: path))
        }
    }
    
    static var persistentState: TuneBrowserPersistentState {
        
        TuneBrowserPersistentState(windowSize: NSSizePersistentState(size: windowSize),
                                   displayedColumns: displayedColumns.map {TuneBrowserTableColumnPersistentState(id: $0.id, width: $0.width)},
                                   sortColumn: sortColumn,
                                   sortIsAscending: sortIsAscending,
                                   sidebar: TuneBrowserSidebarPersistentState(userFolders: sidebarUserFolders.map {TuneBrowserSidebarItemPersistentState(url: $0.url.path)}, width: sidebarWidth))
    }
}
