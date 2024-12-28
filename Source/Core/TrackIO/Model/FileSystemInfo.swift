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
    let fileNameWithExtension: String
    
    let defaultDisplayName: String
    let isNativelySupported: Bool
    
    private lazy var attributes = file.attributes
    
    lazy var kindOfFile: String? = attributes.kindOfFile
    lazy var size: FileSize? = attributes.size
    lazy var creationDate: Date? = attributes.creationDate
    lazy var lastModified: Date? = attributes.lastModified
    lazy var lastOpened: Date? = attributes.lastOpened
    
    init(file: URL) {
        
        self.file = file
        self.fileName = file.nameWithoutExtension
        self.fileNameWithExtension = file.lastPathComponent
        self.isNativelySupported = file.isNativelySupported
        self.defaultDisplayName = self.fileName
    }
}
