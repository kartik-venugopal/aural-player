//
//  FileSystemTrackInfoSource.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 Data source and delegate for the Detailed Track Info popover view
 */
class FileSystemTrackInfoSource: TrackInfoSource {
    
    private(set) var trackInfo: [KeyValuePair] = []
    
    static let instance: FileSystemTrackInfoSource = .init()
    
    private init() {}
    
    private lazy var dateFormatter: DateFormatter = DateFormatter(format: "MMMM dd, yyyy  'at'  hh:mm:ss a")
    
    func loadTrackInfo(for track: Track) {
        
        trackInfo.removeAll()
        
        trackInfo.append(KeyValuePair(key: "Location", value: track.file.path))
        
        trackInfo.append(KeyValuePair(key: "Kind",
                                      value: track.fileSystemInfo.kindOfFile ?? TrackInfoConstants.value_unknown))
        
        trackInfo.append(KeyValuePair(key: "Size",
                                      value: track.fileSystemInfo.size?.description ?? TrackInfoConstants.value_unknown))
        
        if let creationDate = track.fileSystemInfo.creationDate {
            
            trackInfo.append(KeyValuePair(key: "Created",
                                          value: dateFormatter.string(from: creationDate)))
        }
        
        if let lastModifiedDate = track.fileSystemInfo.lastModified {
            
            trackInfo.append(KeyValuePair(key: "Last Modified",
                                          value: dateFormatter.string(from: lastModifiedDate)))
        }
        
        if let openDate = track.fileSystemInfo.lastOpened {
            
            trackInfo.append(KeyValuePair(key: "Last Opened",
                                          value: dateFormatter.string(from: openDate)))
        }
    }
}
