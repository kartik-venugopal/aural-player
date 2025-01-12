//
//  TrackList+TrackIO.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// TODO: *********** How about using an OrderedSet<Track> to collect the tracks ?

// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?

extension TrackList: TrackListFileSystemLoadingProtocol {
    
    func loadTracksAsync(from urls: [URL], atPosition insertionIndex: Int?) {
        
        _isBeingModified.setTrue()
        
        session = TrackLoadSession(forLoader: self, withPriority: trackLoadQoS, urls: urls, insertionIndex: insertionIndex)
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: trackLoadQoS).async {
            
            defer {self._isBeingModified.setFalse()}
            
            self.readURLs(urls)
            
            self.session.allTracksRead()
            
            // Cleanup
            self.session = nil
        }
    }
    
    fileprivate func readURLs(_ urls: [URL]) {
        
        for url in urls {

            // Always resolve sym links and aliases before reading the file
            let resolvedURL = url.resolvedURL

            // TODO: Check if file exists, pass a parm to determine whether or not to check (check only if coming
            // from Favs, Bookms, or History).
        
            if resolvedURL.isDirectory {

                // Directory

                // TODO: This is sorting by filename ... do we want this or something else ? User-configurable "add ordering" ?
                if let dirContents = resolvedURL.children {
                    readURLs(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}))
                }

            } else {
        
                // Track or Playlist
                if resolvedURL.isSupportedAudioFile {
                    session.readTrack(forFile: resolvedURL)
                    
                } else if resolvedURL.isSupportedPlaylistFile {
                    readPlaylistFile(resolvedURL)
                }
            }
        }
    }
    
    fileprivate func readPlaylistFile(_ playlistFile: URL) {
        
        if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: playlistFile) {
            
            loadedPlaylist.tracks.forEach {
                session.readTrack(forFile: $0.file, withCueSheetMetadata: $0.cueSheetMetadata)
            }
        }
        
        // TODO: else mark error in session ??? What to do with playlists with 0 tracks ???
    }
}
