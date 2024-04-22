//
//  TuneBrowserSidebarItems.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

enum TuneBrowserSidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    case volumes = "Volumes"
    case folders = "Folders"
    
    var description: String {rawValue}
}

class TuneBrowserSidebarItem: Equatable {
    
    let folder: FileSystemFolderItem
    let tree: FileSystemTree
    
    init(folder: FileSystemFolderItem, tree: FileSystemTree) {
        
        self.folder = folder
        self.tree = tree
    }
    
    static func == (lhs: TuneBrowserSidebarItem, rhs: TuneBrowserSidebarItem) -> Bool {
        lhs.folder == rhs.folder && lhs.tree == rhs.tree
    }
}
