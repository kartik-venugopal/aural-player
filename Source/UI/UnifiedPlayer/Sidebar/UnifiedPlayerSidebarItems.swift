//
//  UnifiedPlayerSidebarItems.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

enum UnifiedPlayerModule: String, CaseIterable, CustomStringConvertible {
    
//    private static let libraryItems: [UnifiedPlayerSidebarItem] = [
//        
//        UnifiedPlayerSidebarItem(category: .library, displayName: "Tracks", browserTab: .libraryTracks, image: .imgTracks),
//        UnifiedPlayerSidebarItem(category: .library, displayName: "Artists", browserTab: .libraryArtists, image: .imgArtistGroup),
//        UnifiedPlayerSidebarItem(category: .library, displayName: "Albums", browserTab: .libraryAlbums, image: .imgAlbumGroup),
//        UnifiedPlayerSidebarItem(category: .library, displayName: "Genres", browserTab: .libraryGenres, image: .imgGenreGroup),
//        UnifiedPlayerSidebarItem(category: .library, displayName: "Decades", browserTab: .libraryDecades, image: .imgDecadeGroup),
//    ]
//    
//    private static let historyItems: [UnifiedPlayerSidebarItem] = [
//        
//        UnifiedPlayerSidebarItem(category: .history, displayName: "Recently Played", browserTab: .historyRecentlyPlayed),
//        UnifiedPlayerSidebarItem(category: .history, displayName: "Most Played", browserTab: .historyMostPlayed),
//        UnifiedPlayerSidebarItem(category: .history, displayName: "Recently Added", browserTab: .historyRecentlyAdded)
//    ]
    
    case playQueue = "Play Queue"
    case chaptersList = "Chapters List"
    case trackInfo = "Track Info"
    case waveform = "Waveform"
    
    var isTopLevelItem: Bool {
        self.equalsOneOf(.playQueue, .chaptersList, .trackInfo)
    }
    
//    case library = "Library"
//    case tuneBrowser = "File System"
//    case playlists = "Playlists"
//    case history = "History"
//    case favorites = "Favorites"
//    case bookmarks = "Bookmarks"
    
//    var browserTab: UnifiedPlayerBrowserTab {
//        
//        switch self {
//            
//        case .playQueue:
//            
//            return .playQueue
//            
////        case .favorites:
////            
////            return .favorites
////            
////        case .bookmarks:
////            
////            return .favorites
////            
////        default:
////            
////            return .libraryTracks
//        }
//    }
    
    var description: String {rawValue}
    
    var numberOfChildItems: Int {
        0
//
//        switch self {
//            
//        case .library:
//            
//            return Self.libraryItems.count
//            
//        case .tuneBrowser:
//            
//            return tuneBrowserUIState.sidebarUserFolders.count + 1
//            
//        case .playlists:
//            
//            return playlistsManager.numberOfUserDefinedObjects
//            
//        case .history:
//            
//            return Self.historyItems.count
//            
//        case .playQueue, .favorites, .bookmarks:
//            
//            return 0
//        }
    
    }
    
    var childItems: [UnifiedPlayerSidebarItem] {
        
//        switch self {
//            
//        case .library:
//            
//            return Self.libraryItems
//            
//        case .tuneBrowser:
//            
////            return libraryDelegate.fileSystemTrees.map {tree in
////                
////                let rootFolder = tree.root
////                return UnifiedPlayerSidebarItem(category: .tuneBrowser, displayName: rootFolder.name, browserTab: .fileSystem, tuneBrowserFolder: rootFolder, tuneBrowserTree: tree)
////            }
//            
//            // TODO: Also add in the user folders from persistent TB state
//            //            tuneBrowserUIState.sidebarUserFolders.values.map {
//            //                LibrarySidebarItem(displayName: $0.url.lastPathComponent, browserTab: .fileSystem, tuneBrowserURL: $0.url)
//            
//            return []
//            
//        case .playlists:
//            
//            return playlistsManager.playlistNames.map {UnifiedPlayerSidebarItem(category: .playlists, displayName: $0, browserTab: .playlists)}
//            
//        case .history:
//            
//            return Self.historyItems
//            
//        case .playQueue, .favorites, .bookmarks:
            
            return []
//        }
    }
    
    var image: NSImage {
        
        switch self {
            
        case .playQueue:
            
            return .imgPlayQueue
            
        case .chaptersList:
            
            return .imgPlayQueue
            
        case .trackInfo:
            
            return .imgInfo
            
        case .waveform:
            
            return .imgWaveform
            
            //        case .library:
            //
            //            return .imgLibrary
            //
            //        case .tuneBrowser:
            //
            //            return .imgFileSystem
            //
            //        case .playlists:
            //
            //            return .imgPlaylist
            //
            //        case .history:
            //
            //            return .imgHistory
            //
            //        case .favorites:
            //
            //            return .imgFavorite
            //
            //        case .bookmarks:
            //
            //            return .imgBookmark
            //        }
        }
    }
}

// TODO: Consolidate this struct with 'LibrarySidebarItem'
class UnifiedPlayerSidebarItem {
    
    let module: UnifiedPlayerModule
    let childItems: [UnifiedPlayerSidebarItem]
    let isCloseable: Bool
    
    static let playQueueItem: UnifiedPlayerSidebarItem = .init(module: .playQueue, isCloseable: false)
    static let chaptersListItem: UnifiedPlayerSidebarItem = .init(module: .chaptersList)
    
    init(module: UnifiedPlayerModule, childItems: [UnifiedPlayerSidebarItem] = [], isCloseable: Bool = true) {
        
        self.module = module
        self.childItems = childItems
        self.isCloseable = isCloseable
    }
    
    fileprivate func equals(other: UnifiedPlayerSidebarItem) -> Bool {
        self.module == other.module
    }
}

extension UnifiedPlayerSidebarItem: Equatable {
    
    static func ==(lhs: UnifiedPlayerSidebarItem, rhs: UnifiedPlayerSidebarItem) -> Bool {
        lhs.equals(other: rhs)
    }
}

class TrackInfoUnifiedPlayerSidebarItem: UnifiedPlayerSidebarItem {
    
    let track: Track
    
    init(track: Track) {
        
        self.track = track
        super.init(module: .trackInfo)
    }
    
    override func equals(other: UnifiedPlayerSidebarItem) -> Bool {
        super.equals(other: other) && self.track == (other as? TrackInfoUnifiedPlayerSidebarItem)?.track
    }
}

//class TuneBrowserUnifiedPlayerSidebarItem: UnifiedPlayerSidebarItem {
//
//        let tuneBrowserFolder: FileSystemFolderItem?
//        let tuneBrowserTree: FileSystemTree?
//}
