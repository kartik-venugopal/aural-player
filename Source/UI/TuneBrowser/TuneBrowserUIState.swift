//
//  TuneBrowserUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TuneBrowserUIState {
    
    static let defaultWindowSize: NSSize = NSSize(width: 700, height: 500)
    var windowSize: NSSize
    
    var displayedColumns: [TuneBrowserTableColumn] = []
    
    static let defaultSortColumn: String = "name"
    var sortColumn: String
    
    static let defaultSortIsAscending: Bool = true
    var sortIsAscending: Bool
    
    private var sidebarUserFoldersByURL: [URL: TuneBrowserSidebarItem] = [:]
    private(set) var sidebarUserFolders: [TuneBrowserSidebarItem] = []
    
    static let defaultSidebarWidth: CGFloat = 100
    var sidebarWidth: CGFloat
    
    init(persistentState: TuneBrowserUIPersistentState?) {
        
        windowSize = persistentState?.windowSize?.toNSSize() ?? Self.defaultWindowSize
        displayedColumns = persistentState?.displayedColumns?.compactMap {TuneBrowserTableColumn(persistentState: $0)} ?? []
        sortColumn = persistentState?.sortColumn ?? Self.defaultSortColumn
        sortIsAscending = persistentState?.sortIsAscending ?? Self.defaultSortIsAscending
        
        sidebarWidth = persistentState?.sidebar?.width ?? Self.defaultSidebarWidth
        
        for path in (persistentState?.sidebar?.userFolders ?? []).compactMap({$0.url}) {
            addUserFolder(forURL: URL(fileURLWithPath: path))
        }
    }
    
    var persistentState: TuneBrowserUIPersistentState {
        
        TuneBrowserUIPersistentState(windowSize: NSSizePersistentState(size: windowSize),
                                     displayedColumns: displayedColumns.map {TuneBrowserTableColumnPersistentState(id: $0.id, width: $0.width)},
                                     sortColumn: sortColumn,
                                     sortIsAscending: sortIsAscending,
                                     sidebar: TuneBrowserSidebarPersistentState(userFolders: sidebarUserFolders.map {TuneBrowserSidebarItemPersistentState(url: $0.url.path)}, width: sidebarWidth))
    }
    
    func userFolder(forURL url: URL) -> TuneBrowserSidebarItem? {
        sidebarUserFoldersByURL[url]
    }
    
    func addUserFolder(forURL url: URL) {
        
        if sidebarUserFoldersByURL[url] == nil {
            
            let newItem = TuneBrowserSidebarItem(url: url)
            sidebarUserFolders.append(newItem)
            sidebarUserFoldersByURL[url] = newItem
        }
    }
    
    func removeUserFolder(item: TuneBrowserSidebarItem) -> Int? {
        
        sidebarUserFoldersByURL.removeValue(forKey: item.url)
        return sidebarUserFolders.removeItem(item)
    }
}

struct TuneBrowserTableColumn {
    
    let id: String
    let width: CGFloat
    
    init(id: String, width: CGFloat) {
        
        self.id = id
        self.width = width
    }
    
    init?(persistentState: TuneBrowserTableColumnPersistentState) {
        
        guard let id = persistentState.id, let width = persistentState.width else {return nil}
        
        self.id = id
        self.width = width
    }
}
