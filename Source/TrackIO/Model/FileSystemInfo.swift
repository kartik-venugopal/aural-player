//
//  FileSystemInfo.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    private lazy var attributes = file.attributes
    
    var kindOfFile: String? {attributes.kindOfFile}
    var size: FileSize?  {attributes.size}
    var creationDate: Date? {attributes.creationDate}
    var lastModified: Date? {attributes.lastModified}
    var lastOpened: Date? {attributes.lastOpened}
    
    init(file: URL) {
        
        self.file = file
        self.fileName = file.deletingPathExtension().lastPathComponent
    }
}
