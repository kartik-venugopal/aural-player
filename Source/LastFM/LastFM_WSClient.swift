//
//  LastFM_WSClient.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class LastFM_WSClient: LastFM_WSClientProtocol {
    
    private static let webServicesBaseURL: String = "https://ws.audioscrobbler.com/2.0/"
    
    private static let apiKey: String = "ba785720390959ec4080c9f86615f069"
    private static let sharedSecret: String = "e5a700c076a1063a4d52edea30a38099"
    
    private static let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private let httpClient: HTTPClient = .shared
    
    private lazy var messenger: Messenger = .init(for: self)
    
    static let shared: LastFM_WSClient = .init()
    private init() {}
    
    // MARK: Get Token ------------------------------------------------------------
    
    func getToken() throws -> LastFMToken {
        
        let urlString = "\(Self.webServicesBaseURL)?method=auth.getToken&api_key=\(Self.apiKey)&format=json"
        
        guard let url = URL(string: urlString) else {
            throw MalformedLastFMURLError(url: urlString)
        }
        
        let tokenJSON = try httpClient.performGET(toURL: url, withHeaders: [:])
        return try Self.jsonDecoder.decode(LastFMToken.self, from: tokenJSON)
    }
    
    // MARK: Request User auth ------------------------------------------------------------
    
    func requestUserAuthorization(withToken token: LastFMToken) throws {
        
        let urlString = "https://www.last.fm/api/auth/?api_key=\(Self.apiKey)&token=\(token.token)"
        
        guard let url = URL(string: urlString) else {
            throw MalformedLastFMURLError(url: urlString)
        }
        
        NSWorkspace.shared.open(url)
    }
    
    // MARK: Get Session ------------------------------------------------------------
    
    func getSession(forToken token: LastFMToken) throws -> LastFMSession {
        
        let apiSignature = "api_key\(Self.apiKey)methodauth.getSessiontoken\(token.token)\(Self.sharedSecret)".utf8EncodedString().MD5Hex()
        let urlString = "\(Self.webServicesBaseURL)?method=auth.getSession&token=\(token.token)&api_key=\(Self.apiKey)&api_sig=\(apiSignature)&format=json"
        
        guard let url = URL(string: urlString) else {
            throw MalformedLastFMURLError(url: urlString)
        }
        
        let sessionJSON = try httpClient.performGET(toURL: url, withHeaders: [:])
        return (try Self.jsonDecoder.decode(LastFMSessionResponse.self, from: sessionJSON)).session
    }
    
    // MARK: Scrobble Track ------------------------------------------------------------
    
    func scrobbleTrack(track: Track, timestamp: Int, usingSessionKey sessionKey: String) {
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot scrobble track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        do {
            
            let signature = "api_key\(Self.apiKey)artist\(artist)methodtrack.scrobblesk\(sessionKey)timestamp\(timestamp)track\(title)\(Self.sharedSecret)"
                .utf8EncodedString().MD5Hex()
            
            let urlString = "\(Self.webServicesBaseURL)?method=track.scrobble&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(Self.apiKey)&artist=\(artist.encodedAsURLQueryParameter())&timestamp=\(timestamp)&track=\(title.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json"
            
            guard let url = URL(string: urlString) else {
                throw MalformedLastFMURLError(url: urlString)
            }
            
            try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            NSLog("Last.fm: Successfully Scrobbled: Artist='\(artist)', Title='\(title)' !")
            
        } catch let httpError as HTTPError {
            NSLog("Failed to scrobble track '\(track.displayName)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to scrobble track '\(track.displayName)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Love Track ------------------------------------------------------------
    
    func loveTrack(track: Track, usingSessionKey sessionKey: String) {
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot love track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        do {
            
            let signature = "api_key\(Self.apiKey)artist\(artist)methodtrack.lovesk\(sessionKey)track\(track)\(Self.sharedSecret)"
                .utf8EncodedString().MD5Hex()
            
            let urlString = "\(Self.webServicesBaseURL)?method=track.love&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(Self.apiKey)&artist=\(artist.encodedAsURLQueryParameter())&track=\(title.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json"
            
            guard let url = URL(string: urlString) else {
                throw MalformedLastFMURLError(url: urlString)
            }
            
            _ = try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            NSLog("Last.fm: Successfully Loved: Artist='\(artist)', Title='\(title)' !")
            
        } catch let httpError as HTTPError {
            NSLog("Failed to love track '\(track.displayName)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to love track '\(track.displayName)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Unlove Track ------------------------------------------------------------
    
    func unloveTrack(track: Track, usingSessionKey sessionKey: String) {
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot unlove track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        do {
            
            let signature = "api_key\(Self.apiKey)artist\(artist)methodtrack.unlovesk\(sessionKey)track\(track)\(Self.sharedSecret)"
                .utf8EncodedString().MD5Hex()
            
            let urlString = "\(Self.webServicesBaseURL)?method=track.unlove&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(Self.apiKey)&artist=\(artist.encodedAsURLQueryParameter())&track=\(title.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json"
            
            guard let url = URL(string: urlString) else {
                throw MalformedLastFMURLError(url: urlString)
            }
            
            _ = try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            NSLog("Last.fm: Successfully Unloved: Artist='\(artist)', Title='\(title)' !")
            
        } catch let httpError as HTTPError {
            NSLog("Failed to unlove track '\(track.displayName)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to unlove track '\(track.displayName)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
}

class MalformedLastFMURLError: Error, CustomStringConvertible {
    
    private let url: String
    
    init(url: String) {
        self.url = url
    }
    
    var description: String {
        "The URL used to make a Last.fm API call is invalid: '\(url)'"
    }
}

