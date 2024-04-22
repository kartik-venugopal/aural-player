//
//  CoverArtTrackInfoSource.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 Data source and delegate for the Detailed Track Info popover view
 */
class CoverArtTrackInfoSource: TrackInfoSource {
    
    private(set) var trackInfo: [KeyValuePair] = []
    
    func loadTrackInfo(for track: Track) {
        
        trackInfo.removeAll()
        
        guard let artInfo = track.art?.metadata else {return}
        
        if let type = artInfo.type {
            trackInfo.append(KeyValuePair(key: "Type", value: type))
        }
        
        if let dimensions = artInfo.dimensions {
            
            let dimStr = String(format: "%.0f x %.0f", round(dimensions.width), round(dimensions.height))
            trackInfo.append(KeyValuePair(key: "Dimensions", value: dimStr))
        }
        
        if let resolution = artInfo.resolution {
            
            let resStr = String(format: "%.0f x %.0f DPI", round(resolution.width), round(resolution.height))
            trackInfo.append(KeyValuePair(key: "Resolution", value: resStr))
        }
        
        if let colorSpace = artInfo.colorSpace {
            trackInfo.append(KeyValuePair(key: "Color Space", value: colorSpace))
        }
        
        if let colorProfile = artInfo.colorProfile {
            trackInfo.append(KeyValuePair(key: "Color Profile", value: colorProfile))
        }
        
        if let bitDepth = artInfo.bitDepth {
            trackInfo.append(KeyValuePair(key: "Bit Depth", value: String(format: "%d-bit", bitDepth)))
        }
        
        if let hasAlpha = artInfo.hasAlpha {
            trackInfo.append(KeyValuePair(key: "Has Alpha?", value: hasAlpha ? "Yes" : "No"))
        }
    }
}
