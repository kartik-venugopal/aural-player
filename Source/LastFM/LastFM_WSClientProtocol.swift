//
//  LastFM_WSClientProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol LastFM_WSClientProtocol {
    
    func getToken() -> LastFMToken?
    
    func requestUserAuthorization(withToken token: LastFMToken)
    
    func getSession(forToken token: LastFMToken) -> LastFMSession?
    
    func scrobbleTrack(track: Track, timestamp: Int, usingSessionKey sessionKey: String)
    
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
