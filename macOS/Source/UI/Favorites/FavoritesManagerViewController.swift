//
//  FavoritesManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FavoritesManagerViewController: NSViewController {
    
    override var nibName: String? {"FavoritesManager"}
    
    @IBOutlet weak var containerBox: NSBox!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var tabGroup: NSTabView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    lazy var tracksViewController: FavoriteTracksViewController = .init()
    lazy var artistsViewController: FavoriteArtistsViewController = .init()
    lazy var albumsViewController: FavoriteAlbumsViewController = .init()
    lazy var genresViewController: FavoriteGenresViewController = .init()
    lazy var decadesViewController: FavoriteDecadesViewController = .init()
    lazy var playlistFilesViewController: FavoritePlaylistFilesViewController = .init()
    lazy var foldersViewController: FavoriteFoldersViewController = .init()
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        [tracksViewController, artistsViewController, albumsViewController, genresViewController, decadesViewController, 
         playlistFilesViewController, foldersViewController].enumerated().forEach {(index, vc) in
            
            tabGroup.tabViewItem(at: index).view?.addSubview(vc.view)
            vc.view.anchorToSuperview()
        }
        
        updateCaption()
        updateSummary()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: containerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceiver: lblSummary)
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: updateSummary)
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: updateSummary)
    }
    
    func showTab(for sidebarItem: LibrarySidebarItem) {
        
        guard sidebarItem.browserTab == .favorites else {return}
        
        switch sidebarItem.displayName {
            
        case "Tracks":
            tabGroup.selectTabViewItem(at: 0)
            
        case "Artists":
            tabGroup.selectTabViewItem(at: 1)
            
        case "Albums":
            tabGroup.selectTabViewItem(at: 2)
            
        case "Genres":
            tabGroup.selectTabViewItem(at: 3)
            
        case "Decades":
            tabGroup.selectTabViewItem(at: 4)
            
        case "Playlist Files":
            tabGroup.selectTabViewItem(at: 5)
            
        case "Folders":
            tabGroup.selectTabViewItem(at: 6)
            
        default:
            return
        }
        
        updateCaption()
        updateSummary()
    }
    
    func updateCaption() {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            lblCaption.stringValue = "Tracks"
            
        case 1:
            lblCaption.stringValue = "Artists"
            
        case 2:
            lblCaption.stringValue = "Albums"
            
        case 3:
            lblCaption.stringValue = "Genres"
            
        case 4:
            lblCaption.stringValue = "Decades"
            
        case 5:
            lblCaption.stringValue = "Playlist Files"
            
        case 6:
            lblCaption.stringValue = "Folders"
            
        default:
            return
        }
    }
    
    func updateSummary() {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            
            // Tracks
            let numFavorites = favoritesDelegate.numberOfFavoriteTracks
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "track" : "tracks")"
            
        case 1:
            
            // Artists
            let numFavorites = favoritesDelegate.numberOfFavoriteArtists
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "artist" : "artists")"
            
        case 2:
            
            // Albums
            let numFavorites = favoritesDelegate.numberOfFavoriteAlbums
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "album" : "albums")"
            
        case 3:
            
            // Genres
            let numFavorites = favoritesDelegate.numberOfFavoriteGenres
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "genre" : "genres")"
            
        case 4:
            
            // Decades
            let numFavorites = favoritesDelegate.numberOfFavoriteDecades
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "decade" : "decades")"
            
        case 5:
            
            // Playlist Files
            let numFavorites = favoritesDelegate.numberOfFavoritePlaylistFiles
            lblSummary.stringValue = "\(numFavorites)  favorite playlist \(numFavorites == 1 ? "file" : "files")"
            
        case 6:
            
            // Folders
            let numFavorites = favoritesDelegate.numberOfFavoriteFolders
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "folder" : "folders")"
            
        default:
            return
        }
    }
}

extension FavoritesManagerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblSummary.font = systemFontScheme.smallFont
    }
}

extension FavoritesManagerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        lblSummary.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_favoriteColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_favoriteColumn")
}
