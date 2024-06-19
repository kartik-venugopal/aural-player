//
//  FileSystemInfo.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all file-system-related information for a track.
///
class FileSystemInfo {
    
    // The filesystem file that contains the audio track represented by this object
    let file: URL
    let fileName: String
    
    // TODO: Should these be recomputed every time ? File attributes (eg. last opened) can change over the course of an app run.
    
    private lazy var attributes = file.attributes
    
    lazy var kindOfFile: String? = attributes.kindOfFile
    lazy var size: FileSize? = attributes.size
    lazy var creationDate: Date? = attributes.creationDate
    lazy var lastModified: Date? = attributes.lastModified
    lazy var lastOpened: Date? = attributes.lastOpened
    
    init(file: URL, fileName: String) {
        
        self.file = file
        self.fileName = fileName
    }
}
