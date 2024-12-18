//
// LastFM_WSClient+Scrobble.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension LastFM_WSClient {
    
    func scrobbleTrack(track: Track, timestamp: Int) {
        
        guard let sessionKey = self.sessionKey else {
            
            NSLog("Cannot scrobble track '\(track)' on Last.fm because no session key is available.")
            return
        }
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot scrobble track '\(track)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        doScrobbleTrack(artist: artist, title: title, album: track.album, timestamp: timestamp, usingSessionKey: sessionKey)
    }
    
    func scrobbleTrack(artist: String, title: String, album: String?, timestamp: Int) {
        
        guard let sessionKey = self.sessionKey else {
            
            NSLog("Cannot love track '\(artist) - \(title)' on Last.fm because no session key is available.")
            return
        }
        
        doScrobbleTrack(artist: artist, title: title, album: album, timestamp: timestamp, usingSessionKey: sessionKey)
    }
    
    private func doScrobbleTrack(artist: String, title: String, album: String?, timestamp: Int, usingSessionKey sessionKey: String) {
        
        var failed: Bool = false
        
        do {
            
            var signature = "api_key\(Self.apiKey)artist\(artist)methodtrack.scrobblesk\(sessionKey)timestamp\(timestamp)track\(title)\(Self.sharedSecret)"
            
            if let album {
                signature = "album\(album)" + signature
            }
            
            var urlString = "\(Self.webServicesBaseURL)?method=track.scrobble&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(Self.apiKey)&artist=\(artist.encodedAsURLQueryParameter())&timestamp=\(timestamp)&track=\(title.encodedAsURLQueryParameter())&api_sig=\(signature.utf8EncodedString().MD5Hex())&format=json"
            
            if let album {
                urlString += "&album=\(album.encodedAsURLQueryParameter())"
            }
            
            guard let url = URL(string: urlString) else {
                throw MalformedLastFMURLError(url: urlString)
            }
            
            try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            
        } catch let httpError as HTTPError {
            
            NSLog("Failed to scrobble track '\(artist) - \(title)' on Last.fm. HTTP Error: \(httpError.code)")
            failed = true
            
        } catch {
            NSLog("Failed to scrobble track '\(artist) - \(title)' on Last.fm. Error: \(error.localizedDescription)")
            failed = true
        }
        
        if failed {
            cache.markFailedScrobbleAttempt(artist: artist, title: title, album: album, timestamp: timestamp)
        } else {
            cache.invalidateEntry(artist: artist, title: title, album: album)
        }
    }
    
    func retryFailedScrobbleAttempts() {
        
        guard self.scrobblingEnabled else {return}
        
        for entry in cache.allEntries {
            
            retryOpQueue.addOperation {
                self.scrobbleTrack(artist: entry.artist, title: entry.title, album: entry.album, timestamp: entry.timestamp)
            }
        }
    }
}
