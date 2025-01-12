//
//  SearchResultMatch.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// Describes how a search query matched a particular track, i.e which
/// field matched the query and the value of that field within the track.
///
struct SearchResultMatch {

    let fieldKey: String
    let fieldValue: String
}
