//
//  FileSystemFolderLocation.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct FileSystemFolderLocation: Equatable {
    
    let folder: FileSystemFolderItem
    let tree: FileSystemTree
    
    var folderName: String {
        folder.name
    }
    
    var folderURL: URL {
        folder.url
    }
    
    var rootFolderURL: URL {
        tree.rootURL
    }
    
    static func == (lhs: FileSystemFolderLocation, rhs: FileSystemFolderLocation) -> Bool {
        lhs.tree == rhs.tree && lhs.folder == rhs.folder
    }
}
