//
//  FileSystemTrackInfoViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class FileSystemTrackInfoViewDelegate: TrackInfoViewDelegate {
    
    override var tableId: TrackInfoTab {return .fileSystem}
    
    private lazy var dateFormatter: DateFormatter = DateFormatter(format: "MMMM dd, yyyy  'at'  hh:mm:ss a")
    
    override func infoForTrack(_ track: Track) -> [KeyValuePair] {
        
        var trackInfo: [KeyValuePair] = []
        
        trackInfo.append((key: "Location", value: track.file.path))
        
        if let kindOfFile = track.fileSystemInfo.kindOfFile {
            trackInfo.append((key: "Kind", value: kindOfFile))
        }
        
        trackInfo.append((key: "Size", value: track.fileSystemInfo.size!.description))
        trackInfo.append((key: "Created", value: dateFormatter.string(from: track.fileSystemInfo.creationDate!)))
        trackInfo.append((key: "Last Modified", value: dateFormatter.string(from: track.fileSystemInfo.lastModified!)))
        
        if let openDate = track.fileSystemInfo.lastOpened {
            trackInfo.append((key: "Last Opened", value: dateFormatter.string(from: openDate)))
        }
        
        return trackInfo
    }
}
