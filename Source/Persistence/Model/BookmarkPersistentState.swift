//
//  BookmarkPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct BookmarkPersistentState: Codable {
    
    let name: String?
    let file: URL?
    let startPosition: Double?
    let endPosition: Double?
}
