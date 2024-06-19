//
//  SidebarItems.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

enum LibrarySidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    private static let libraryItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Tracks", browserTab: .libraryTracks, image: .imgTracks),
        LibrarySidebarItem(displayName: "Artists", browserTab: .libraryArtists, image: .imgArtistGroup),
        LibrarySidebarItem(displayName: "Albums", browserTab: .libraryAlbums, image: .imgAlbumGroup),
        LibrarySidebarItem(displayName: "Genres", browserTab: .libraryGenres, image: .imgGenreGroup),
        LibrarySidebarItem(displayName: "Decades", browserTab: .libraryDecades, image: .imgDecadeGroup),
        LibrarySidebarItem(displayName: "Playlist Files", browserTab: .libraryImportedPlaylists, image: .imgPlaylist)
    ]
    
    private static let favoritesItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Tracks", browserTab: .favorites, image: .imgTracks),
        LibrarySidebarItem(displayName: "Artists", browserTab: .favorites, image: .imgArtistGroup),
        LibrarySidebarItem(displayName: "Albums", browserTab: .favorites, image: .imgAlbumGroup),
        LibrarySidebarItem(displayName: "Genres", browserTab: .favorites, image: .imgGenreGroup),
        LibrarySidebarItem(displayName: "Decades", browserTab: .favorites, image: .imgDecadeGroup),
        LibrarySidebarItem(displayName: "Playlist Files", browserTab: .favorites, image: .imgPlaylist),
        LibrarySidebarItem(displayName: "Folders", browserTab: .favorites, image: .imgFileSystem)
    ]
    
    private static let historyItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Recent Items", browserTab: .historyRecentItems),
        LibrarySidebarItem(displayName: "Frequent items", browserTab: .historyFrequentItems),
    ]
    
    case library = "Library"
    case tuneBrowser = "File System"
    case playlists = "Playlists"
    case favorites = "Favorites"
    case bookmarks = "Bookmarks"
    case history = "History"
    
    var description: String {rawValue}
    
    var numberOfItems: Int {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems.count
            
        case .tuneBrowser:
            
            return libraryDelegate.fileSystemTrees.count + tuneBrowserUIState.sidebarUserFolders.count
            
        case .playlists:
            
            return playlistsManager.numberOfUserDefinedObjects
            
        case .favorites:
            
            return Self.favoritesItems.count
            
        case .bookmarks:
            
            return 0
            
        case .history:
            
            return Self.historyItems.count
        }
    }
    
    var items: [LibrarySidebarItem] {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems
            
        case .tuneBrowser:
            
            return libraryDelegate.fileSystemTrees.map {tree in
                
                let rootFolder = tree.root
                return LibrarySidebarItem(displayName: rootFolder.name, browserTab: .fileSystem, tuneBrowserFolder: rootFolder, tuneBrowserTree: tree)
                
            } + tuneBrowserUIState.sidebarUserFolders.map {
                LibrarySidebarItem(displayName: $0.folder.name, browserTab: .fileSystem, tuneBrowserFolder: $0.folder, tuneBrowserTree: $0.tree)
            }
            
        case .playlists:
            
            return playlistsManager.userDefinedObjects.map {
                LibrarySidebarItem(displayName: $0.name, browserTab: .playlists)
            }
            
        case .favorites:
            
            return Self.favoritesItems
            
        case .bookmarks:
            
            return []
            
        case .history:
            
            return Self.historyItems
        }
    }
    
    var image: NSImage {
        
        switch self {
            
        case .library:
            
            return .imgLibrary
            
        case .tuneBrowser:
            
            return .imgFileSystem
            
        case .playlists:
            
            return .imgPlaylist
            
        case .favorites:
            
            return .imgFavorite
            
        case .bookmarks:
            
            return .imgBookmark
            
        case .history:
            
            return .imgHistory
        }
    }
}

class LibrarySidebarItem: Equatable {
    
    var displayName: String
    let browserTab: LibraryBrowserTab
    let image: NSImage?
    
    let tuneBrowserFolder: FileSystemFolderItem?
    let tuneBrowserTree: FileSystemTree?
    
    init(displayName: String, browserTab: LibraryBrowserTab, tuneBrowserFolder: FileSystemFolderItem? = nil, tuneBrowserTree: FileSystemTree? = nil, image: NSImage? = nil) {
        
        self.displayName = displayName
        self.browserTab = browserTab
        
        self.tuneBrowserFolder = tuneBrowserFolder
        self.tuneBrowserTree = tuneBrowserTree
        
        self.image = image
    }
    
    static func == (lhs: LibrarySidebarItem, rhs: LibrarySidebarItem) -> Bool {
        
        if lhs.browserTab != rhs.browserTab {
            return false
        }
        
        if lhs.browserTab != .fileSystem {
            return true
        }
        
        // Same folder implies same tree
        return lhs.tuneBrowserFolder == rhs.tuneBrowserFolder
    }
}

enum LibraryBrowserTab: Int {
    
    case libraryTracks = 0,
         libraryArtists = 1,
         libraryAlbums = 2,
         libraryGenres = 3,
         libraryDecades = 4,
         libraryImportedPlaylists = 5,
         fileSystem = 6,
         playlists = 7,
         favorites = 8,
         bookmarks = 9,
         historyRecentItems = 10,
         historyFrequentItems = 11
}
