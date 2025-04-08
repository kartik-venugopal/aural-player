//
// LastFM_WSClient+LoveUnlove.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension LastFM_WSClient {
    
    // MARK: Love Track ------------------------------------------------------------
    
    func loveTrack(track: Track) {
        
        guard let sessionKey = self.sessionKey else {
            
            NSLog("Cannot love track '\(track)' on Last.fm because no session key is available.")
            return
        }
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot love track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        doLoveTrack(artist: artist, title: title, usingSessionKey: sessionKey)
    }
    
    private func doLoveTrack(artist: String, title: String, usingSessionKey sessionKey: String) {
        
        do {
            
            let signature = "api_key\(Self.apiKey)artist\(artist)methodtrack.lovesk\(sessionKey)track\(title)\(Self.sharedSecret)"
                .utf8EncodedString().MD5Hex()
            
            let urlString = "\(Self.webServicesBaseURL)?method=track.love&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(Self.apiKey)&artist=\(artist.encodedAsURLQueryParameter())&track=\(title.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json"
            
            guard let url = URL(string: urlString) else {
                throw MalformedLastFMURLError(url: urlString)
            }
            
            _ = try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            
        } catch let httpError as HTTPError {
            NSLog("Failed to love track '\(artist) - \(title)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to love track '\(artist) - \(title)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Un-love Track ------------------------------------------------------------
    
    func unloveTrack(track: Track) {
        
        guard let sessionKey = self.sessionKey else {
            
            NSLog("Cannot un-love track '\(track)' on Last.fm because no session key is available.")
            return
        }
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot un-love track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        doUnloveTrack(artist: artist, title: title, usingSessionKey: sessionKey)
    }
    
    private func doUnloveTrack(artist: String, title: String, usingSessionKey sessionKey: String) {
        
        do {
            
            let signature = "api_key\(Self.apiKey)artist\(artist)methodtrack.unlovesk\(sessionKey)track\(title)\(Self.sharedSecret)"
                .utf8EncodedString().MD5Hex()
            
            let urlString = "\(Self.webServicesBaseURL)?method=track.unlove&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(Self.apiKey)&artist=\(artist.encodedAsURLQueryParameter())&track=\(title.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json"
            
            guard let url = URL(string: urlString) else {
                throw MalformedLastFMURLError(url: urlString)
            }
            
            _ = try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            
        } catch let httpError as HTTPError {
            NSLog("Failed to un-love track '\(artist) - \(title)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to un-love track '\(artist) - \(title)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Message handling ------------------------------------------------------------
    
    func favoriteAdded(favorite: Favorite) {
        
        // TODO: Can we love/unlove a non-track ???
        
        guard self.loveUnloveEnabled,
              let favTrack = favorite as? FavoriteTrack else {return}
        
        DispatchQueue.global(qos: .background).async {
            self.loveTrack(track: favTrack.track)
        }
    }
    
    func favoritesRemoved(favorites: Set<Favorite>) {
        
        guard lastFMPreferences.enableLoveUnlove else {return}
        
        DispatchQueue.global(qos: .background).async {
            
            for favorite in favorites {
                
                if let track = (favorite as? FavoriteTrack)?.track {
                    self.unloveTrack(track: track)
                }
            }
        }
    }
}
