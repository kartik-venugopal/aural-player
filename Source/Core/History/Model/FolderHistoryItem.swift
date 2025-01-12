//
//  FolderHistoryItem.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FolderHistoryItem: HistoryItem {
    
    let folder: URL
    
    init(folder: URL, addCount: HistoryEventCounter, playCount: HistoryEventCounter) {
        
        self.folder = folder
        
        super.init(displayName: folder.lastPathComponents(count: 2),
                   key: Self.key(forFolder: folder),
                   addCount: addCount,
                   playCount: playCount)
    }
    
    static func key(forFolder folder: URL) -> CompositeKey {
        .init(primaryKey: "folder", secondaryKey: folder.path)
    }
}
