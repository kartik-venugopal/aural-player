//
//  FileSystemItem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FileSystemItem {
    
    private static var itemCache: ConcurrentMap<URL, FileSystemItem> = ConcurrentMap()
    
    static func create(forURL url: URL, loadChildren: Bool = false) -> FileSystemItem {
        
        if let item = itemCache[url] {
            return item
        }
        
        let item = FileSystemItem(url: url, loadChildren: loadChildren)
        itemCache[url] = item
        
        return item
    }
    
    let url: URL
    let path: String
    let name: String
    let fileExtension: String
    
    lazy var children: [FileSystemItem] = loadChildren(url)
    var metadataLoadedForChildren: Bool = false
    
    var isDirectory: Bool {url.hasDirectoryPath}
    
    var isPlaylist: Bool {SupportedTypes.playlistExtensions.contains(fileExtension)}
    
    var isTrack: Bool {SupportedTypes.allAudioExtensions.contains(fileExtension)}
    
    var metadata: FileMetadata?
    
    private init(url: URL, loadChildren: Bool = false) {
        
        self.url = url
        self.fileExtension = url.lowerCasedExtension
        self.path = url.path
        self.name = url.lastPathComponent
        
        if loadChildren {
            _ = self.children
        }
    }
    
    private func loadChildren(_ dir: URL) -> [FileSystemItem] {
        
        guard dir.hasDirectoryPath, let dirContents = dir.children else {return []}
        
        return dirContents.map{FileSystemItem.create(forURL: $0)}
            .filter {$0.isTrack || $0.isDirectory || $0.isPlaylist}
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
    }
}
