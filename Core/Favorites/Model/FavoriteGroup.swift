//
//  FavoriteGroup.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FavoriteGroup: Favorite {
    
    let groupName: String
    let groupType: GroupType
    
    override var key: String {
        "\(groupType.rawValue)_\(groupName)"
    }
    
    init(groupName: String, groupType: GroupType) {
        
        self.groupName = groupName
        self.groupType = groupType
        
        super.init(name: groupName)
    }
}
