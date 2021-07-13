//
//  TuneBrowserState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TuneBrowserState {
    
    static let defaultWindowSize: NSSize = NSSize(width: 700, height: 500)
    static var windowSize: NSSize = defaultWindowSize
    
    static var displayedColumns: [TuneBrowserTableColumn] = []
    
    private static var sidebarUserFoldersByURL: [URL: TuneBrowserSidebarItem] = [:]
    
    private(set) static var sidebarUserFolders: [TuneBrowserSidebarItem] = []
    
    static let defaultSidebarWidth: CGFloat = 100
    static var sidebarWidth: CGFloat = defaultSidebarWidth
    
    static func userFolder(forURL url: URL) -> TuneBrowserSidebarItem? {
        sidebarUserFoldersByURL[url]
    }
    
    static func addUserFolder(forURL url: URL) {
        
        if sidebarUserFoldersByURL[url] == nil {
            
            let newItem = TuneBrowserSidebarItem(url: url)
            sidebarUserFolders.append(newItem)
            sidebarUserFoldersByURL[url] = newItem
        }
    }
    
    static func removeUserFolder(item: TuneBrowserSidebarItem) -> Int? {
        
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
