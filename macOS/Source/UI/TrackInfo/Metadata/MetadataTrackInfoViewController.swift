//
//  MetadataTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MetadataTrackInfoViewController: TrackInfoKVListViewController {
    
    override var trackInfoSource: TrackInfoSource {
        MetadataTrackInfoSource.instance
    }
    
    override var htmlTableName: String {"Metadata"}
}
