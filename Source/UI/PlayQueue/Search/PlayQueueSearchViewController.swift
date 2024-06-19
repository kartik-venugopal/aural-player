//
//  PlayQueueSearchViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class PlayQueueSearchViewController: SearchViewController {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        searchQuery.scope = .playQueue
    }
}
