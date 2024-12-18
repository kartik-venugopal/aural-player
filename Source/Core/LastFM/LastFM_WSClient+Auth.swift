//
// LastFM_WSClient+Auth.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension LastFM_WSClient {
    
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
