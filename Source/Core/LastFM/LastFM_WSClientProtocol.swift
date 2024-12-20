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
    
    func scrobbleTrackIfEligible(_ track: Track)
    
    func scrobbleTrack(track: Track, timestamp: Int)
    
    func scrobbleTrack(artist: String, title: String, album: String?, timestamp: Int)
    
    func retryFailedScrobbleAttempts()
    
    func loveTrack(track: Track)
    
    func unloveTrack(track: Track)
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
