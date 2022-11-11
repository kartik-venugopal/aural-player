//
//  FileCoverArtReader.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An implementation of **CoverArtReaderProtocol** that reads cover art
/// directly from the input file on disk.
///
/// - SeeAlso: `CoverArtReaderProtocol`
///
class FileCoverArtReader: CoverArtReaderProtocol {
    
    private var fileReader: FileReaderProtocol
    
    private var searchedTracks: ConcurrentSet<Track> = ConcurrentSet()
    
    init(_ fileReader: FileReaderProtocol) {
        self.fileReader = fileReader
    }
 
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        
        if searchedTracks.contains(track) {return nil}
        
        // For non-native tracks, check if we already have a file context
        // to read cover art from.
        
        if let plbkContext = track.playbackContext as? FFmpegPlaybackContext,
           let fileCtx = plbkContext.fileContext {
           
            if let imageData = fileCtx.bestImageStream?.attachedPic.data {
                return CoverArt(imageData: imageData)
            }
            
            searchedTracks.insert(track)
            return nil
        }
        
        let art = fileReader.getArt(for: track.file)
        if art == nil {
            searchedTracks.insert(track)
        }
        
        return art
    }
}
