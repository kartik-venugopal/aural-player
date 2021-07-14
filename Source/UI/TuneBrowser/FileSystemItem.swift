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
    let type: FileSystemItemType
    
    lazy var children: [FileSystemItem] = loadChildren(url)
    var metadataLoadedForChildren: Bool = false
    
    var isDirectory: Bool {type == .folder}
    
    var isPlaylist: Bool {type == .playlist}
    
    var isTrack: Bool {type == .track}
    
    var metadata: FileMetadata?
    
    private init(url: URL, loadChildren: Bool = false) {
        
        self.url = url
        self.fileExtension = url.lowerCasedExtension
        self.path = url.path
        self.name = url.lastPathComponent
        
        if url.isDirectory {
            self.type = .folder
            
        } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
            self.type = .track
            
        } else if SupportedTypes.playlistExtensions.contains(fileExtension) {
            self.type = .playlist
            
        } else {
            self.type = .unsupported
        }
        
        if loadChildren && type != .unsupported {
            _ = self.children
        }
    }
    
    private func loadChildren(_ dir: URL) -> [FileSystemItem] {
        
        guard dir.hasDirectoryPath, let dirContents = dir.children else {return []}
        
        return dirContents.map {FileSystemItem.create(forURL: $0)}
            .filter {$0.isTrack || $0.isDirectory || $0.isPlaylist}
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
    }
    
    func sort(by sortField: FileSystemSortField, ascending: Bool) {
        
        switch sortField {
        
        case .name:
            
            children.sort(by: ascending ? {$0.name < $1.name} : {$0.name > $1.name})
            
        case .title:
            
            children.sort(by: {
                
                let title0: String = $0.metadata?.playlist?.title ?? ""
                let title1: String = $1.metadata?.playlist?.title ?? ""
                
                return ascending ? title0 < title1 : title0 > title1
            })
            
        case .artist:
            
            children.sort(by: {
                
                let artist0: String = $0.metadata?.playlist?.artist ?? ""
                let artist1: String = $1.metadata?.playlist?.artist ?? ""
                
                return ascending ? artist0 < artist1 : artist0 > artist1
            })
            
        case .album:
            
            children.sort(by: {
                
                let album0: String = $0.metadata?.playlist?.album ?? ""
                let album1: String = $1.metadata?.playlist?.album ?? ""
                
                return ascending ? album0 < album1 : album0 > album1
            })
            
        case .genre:
            
            children.sort(by: {
                
                let genre0: String = $0.metadata?.playlist?.genre ?? ""
                let genre1: String = $1.metadata?.playlist?.genre ?? ""
                
                return ascending ? genre0 < genre1 : genre0 > genre1
            })
            
        case .format:
            
            children.sort(by: {
                
                let metadata0: AudioInfo? = $0.metadata?.auxiliary?.audioInfo
                let metadata1: AudioInfo? = $1.metadata?.auxiliary?.audioInfo
                
                let format0: String = metadata0?.codec ?? metadata0?.format ?? ""
                let format1: String = metadata1?.codec ?? metadata1?.format ?? ""
                
                return ascending ? format0 < format1 : format0 > format1
            })
            
        case .duration:
            
            children.sort(by:   {
                
                let duration0: Double = $0.metadata?.playlist?.duration ?? 0
                let duration1: Double = $1.metadata?.playlist?.duration ?? 0
                
                return ascending ? duration0 < duration1 : duration0 > duration1
            } )
            
        case .year:
            
            children.sort(by:   {
                
                let year0: Int = $0.metadata?.playlist?.year ?? 0
                let year1: Int = $1.metadata?.playlist?.year ?? 0
                
                return ascending ? year0 < year1 : year0 > year1
            } )
            
        case .type:
            
            children.sort(by: {ascending ? $0.type < $1.type : $0.type > $1.type})
        }
    }
}

enum FileSystemItemType: Int, Comparable {
    
    case folder = 1
    case track = 2
    case playlist = 3
    case unsupported = 4
    
    static func < (lhs: FileSystemItemType, rhs: FileSystemItemType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
