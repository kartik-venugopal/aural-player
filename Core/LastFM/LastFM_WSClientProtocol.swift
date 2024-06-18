//
//  LastFM_WSClientProtocol.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol LastFM_WSClientProtocol {
    
    func getToken() throws -> LastFMToken
    
    func requestUserAuthorization(withToken token: LastFMToken) throws
    
    func getSession(forToken token: LastFMToken) throws -> LastFMSession
    
    func scrobbleTrack(track: Track, timestamp: Int, usingSessionKey sessionKey: String)
    
    func scrobbleTrack(artist: String, title: String, album: String?, timestamp: Int, usingSessionKey sessionKey: String)
    
    func retryFailedScrobbleAttempts()
    
    func loveTrack(track: Track, usingSessionKey sessionKey: String)
    
    func unloveTrack(track: Track, usingSessionKey sessionKey: String)
}

struct LastFMToken: Codable {
    
    let token: String
}

struct LastFMSessionResponse: Codable {
    
    let session: LastFMSession
}

struct LastFMSession: Codable {
    
    let name: String
    let key: String
    let subscriber: Int
}
