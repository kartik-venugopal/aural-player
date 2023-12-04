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
    
    static let shared: LastFM_WSClient = .init()
    private init() {}
    
    // MARK: Get Token ------------------------------------------------------------
    
    private static let getTokenRequestURL: URL? =
        URL(string: "\(webServicesBaseURL)?method=auth.getToken&api_key=\(apiKey)&format=json")
    
    func getToken() -> LastFMToken? {
        
        do {
            
            guard let url = Self.getTokenRequestURL else {return nil}
            
            let tokenJSON = try httpClient.performGET(toURL: url, withHeaders: [:])
            return try Self.jsonDecoder.decode(LastFMToken.self, from: tokenJSON)
            
        } catch let httpError as HTTPError {
            
            NSLog("Failed to get Last.fm API token. HTTP Error: \(httpError.code)")
            return nil
            
        } catch {
            
            NSLog("Failed to get Last.fm API token. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: Request User auth ------------------------------------------------------------
    
    private static func getLastFM_APIAuthURL(forToken token: String) -> URL? {
        URL(string: "https://www.last.fm/api/auth/?api_key=\(apiKey)&token=\(token)")
    }
    
    func requestUserAuthorization(withToken token: LastFMToken) {
        
        if let url = Self.getLastFM_APIAuthURL(forToken: token.token) {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: Get Session ------------------------------------------------------------
    
    private static func getSessionAPISignature(forToken token: String) -> String {
        "api_key\(apiKey)methodauth.getSessiontoken\(token)\(sharedSecret)".utf8EncodedString().MD5Hex()
    }
    
    private static func getSessionRequestURL(forToken token: String) -> URL? {
        URL(string: "\(webServicesBaseURL)?method=auth.getSession&token=\(token)&api_key=\(apiKey)&api_sig=\(getSessionAPISignature(forToken: token))&format=json")
    }
    
    func getSession(forToken token: LastFMToken) -> LastFMSession? {
        
        do {
            
            guard let url = Self.getSessionRequestURL(forToken: token.token) else {return nil}
            
            let sessionJSON = try httpClient.performGET(toURL: url, withHeaders: [:])
            return (try Self.jsonDecoder.decode(LastFMSessionResponse.self, from: sessionJSON)).session
            
        } catch let httpError as HTTPError {
            
            NSLog("Failed to get Last.fm API session key. HTTP Error: \(httpError.code)")
            return nil
            
        } catch {
            
            NSLog("Failed to get Last.fm API session key. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: Scrobble Track ------------------------------------------------------------
    
    private static func getTrackScrobbleAPISignature(forSessionKey sessionKey: String, artist: String, track: String, timestamp: Int) -> String {
        "api_key\(apiKey)artist\(artist)methodtrack.scrobblesk\(sessionKey)timestamp\(timestamp)track\(track)\(sharedSecret)".utf8EncodedString().MD5Hex()
    }
    
    private static func getTrackScrobbleURL(forSessionKey sessionKey: String, artist: String, track: String, timestamp: Int, signature: String) -> URL? {
        URL(string: "\(webServicesBaseURL)?method=track.scrobble&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(apiKey)&artist=\(artist.encodedAsURLQueryParameter())&timestamp=\(timestamp)&track=\(track.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json")
    }
    
    func scrobbleTrack(track: Track, timestamp: Int, usingSessionKey sessionKey: String) {
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot scrobble track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        do {
            
            let signature = Self.getTrackScrobbleAPISignature(forSessionKey: sessionKey, artist: artist, track: title, timestamp: timestamp)
            guard let url = Self.getTrackScrobbleURL(forSessionKey: sessionKey, artist: artist, track: title, timestamp: timestamp, signature: signature) else {
                return
            }
            
            try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            print("Successfully Scrobbled: Artist='\(artist)', Title='\(title)' !")
            
        } catch let httpError as HTTPError {
            NSLog("Failed to scrobble track '\(track.displayName)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to scrobble track '\(track.displayName)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Love Track ------------------------------------------------------------
    
    private static func getTrackLoveAPISignature(forSessionKey sessionKey: String, artist: String, track: String) -> String {
        "api_key\(apiKey)artist\(artist)methodtrack.lovesk\(sessionKey)track\(track)\(sharedSecret)".utf8EncodedString().MD5Hex()
    }
    
    private static func getTrackLoveURL(forSessionKey sessionKey: String, artist: String, track: String, signature: String) -> URL? {
        URL(string: "\(webServicesBaseURL)?method=track.love&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(apiKey)&artist=\(artist.encodedAsURLQueryParameter())&track=\(track.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json")
    }
    
    func loveTrack(track: Track, usingSessionKey sessionKey: String) {
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot love track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        do {
            
            let signature = Self.getTrackLoveAPISignature(forSessionKey: sessionKey, artist: artist, track: title)
            guard let url = Self.getTrackLoveURL(forSessionKey: sessionKey, artist: artist, track: title, signature: signature) else {
                return
            }
            
            _ = try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            print("Successfully Loved: Artist='\(artist)', Title='\(title)' !")
            
        } catch let httpError as HTTPError {
            NSLog("Failed to love track '\(track.displayName)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to love track '\(track.displayName)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Unlove Track ------------------------------------------------------------
    
    private static func getTrackUnloveAPISignature(forSessionKey sessionKey: String, artist: String, track: String) -> String {
        "api_key\(apiKey)artist\(artist)methodtrack.unlovesk\(sessionKey)track\(track)\(sharedSecret)".utf8EncodedString().MD5Hex()
    }
    
    private static func getTrackUnloveURL(forSessionKey sessionKey: String, artist: String, track: String, signature: String) -> URL? {
        URL(string: "\(webServicesBaseURL)?method=track.unlove&sk=\(sessionKey.encodedAsURLQueryParameter())&api_key=\(apiKey)&artist=\(artist.encodedAsURLQueryParameter())&track=\(track.encodedAsURLQueryParameter())&api_sig=\(signature)&format=json")
    }
    
    func unloveTrack(track: Track, usingSessionKey sessionKey: String) {
        
        guard let artist = track.artist, let title = track.title else {
            
            NSLog("Cannot unlove track '\(track.displayName)' on Last.fm because it does not have both title and artist metadata.")
            return
        }
        
        do {
            
            let signature = Self.getTrackUnloveAPISignature(forSessionKey: sessionKey, artist: artist, track: title)
            guard let url = Self.getTrackUnloveURL(forSessionKey: sessionKey, artist: artist, track: title, signature: signature) else {
                return
            }
            
            _ = try httpClient.performPOST(toURL: url, withHeaders: [:], withBody: nil)
            print("Successfully Unloved: Artist='\(artist)', Title='\(title)' !")
            
        } catch let httpError as HTTPError {
            NSLog("Failed to unlove track '\(track.displayName)' on Last.fm. HTTP Error: \(httpError.code)")
            
        } catch {
            NSLog("Failed to unlove track '\(track.displayName)' on Last.fm. Error: \(error.localizedDescription)")
        }
    }
}
