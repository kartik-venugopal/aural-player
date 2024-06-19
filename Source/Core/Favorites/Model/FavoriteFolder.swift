//
//  FavoriteFolder.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FavoriteFolder: Favorite {
    
    let folder: URL
    
    override var key: String {
        folder.path
    }
    
    init(folder: URL) {
        
        self.folder = folder
        super.init(name: folder.lastPathComponents(count: 2))
    }
}
