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

struct TuneBrowserPersistentState: Codable {
    
    let windowSize: NSSizePersistentState?
    let displayedColumns: [TuneBrowserTableColumnPersistentState]?
    let sortColumn: String?
    let sortIsAscending: Bool?
    let sidebar: TuneBrowserSidebarPersistentState?
}

struct TuneBrowserTableColumnPersistentState: Codable {
    
    let id: String?
    let width: CGFloat?
}

struct TuneBrowserSidebarPersistentState: Codable {
    
    let userFolders: [TuneBrowserSidebarItemPersistentState]?
    let width: CGFloat?
}

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
