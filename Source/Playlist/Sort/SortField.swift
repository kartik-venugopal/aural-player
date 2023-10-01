//
//  SortField.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// An enumeration of fields that can be used as playlist sort criteria.
///
enum SortField {
    
    case name
    case duration
    case artist
    case album
    case discNumberAndTrackNumber
    case fileLastModifiedTime
}
