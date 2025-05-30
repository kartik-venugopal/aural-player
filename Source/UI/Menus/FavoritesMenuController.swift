//
//  FavoritesMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FavoritesMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var addRemoveFavoritesMenuItem: ToggleMenuItem!
//    @IBOutlet weak var manageFavoritesMenuItem: NSMenuItem?
    
    @IBOutlet weak var favoriteTracksMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteFoldersMenuItem: NSMenuItem!
    
    private lazy var messenger = Messenger(for: self)
    
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        addRemoveFavoritesMenuItem.off()
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // These menu item actions are only available when a track is currently playing/paused
        addRemoveFavoritesMenuItem.enableIf(player.state.isPlayingOrPaused)
        
        // Menu has 3 static items
//        manageFavoritesMenuItem?.enableIf(favorites.hasAnyFavorites)
        
        let numFavTracks = favorites.numberOfFavoriteTracks
        let numFavFolders = favorites.numberOfFavoriteFolders
        
        favoriteTracksMenuItem.title = "Tracks (\(numFavTracks))"
        favoriteTracksMenuItem.enableIf(numFavTracks > 0)
        
        favoriteFoldersMenuItem.title = "Folders (\(numFavFolders))"
        favoriteFoldersMenuItem.enableIf(numFavFolders > 0)
    }

    func menuWillOpen(_ menu: NSMenu) {
        
        if let playingTrack = player.playingTrack {
            addRemoveFavoritesMenuItem.onIf(favorites.favoriteExists(track: playingTrack))
        } else {
            addRemoveFavoritesMenuItem.off()
        }
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func playingTrackFavoritesAction(_ sender: Any) {
        messenger.publish(.Favorites.addOrRemove)
    }
    
    // Opens the presets manager to manage favorites
    @IBAction func manageFavoritesAction(_ sender: Any) {
        // TODO: Open Library and switch to the Favorite Tracks tab
    }
}

// MARK: Favorite Tracks menu --------------------------------------------

class GenericFavoritesMenuController: NSObject, NSMenuDelegate {
    
    var favoritesFunction: () -> [Favorite] {
        {[]}
    }
    
    var itemImageFunction: (Favorite) -> NSImage? {
        {_ in nil}
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Remove existing items, before re-creating the menu.
        menu.removeAllItems()

        let playAction = #selector(self.playSelectedItemAction(_:))
        
        // Recreate the menu (reverse so that newer items appear first).
        for fav in favoritesFunction().reversed() {
            
            let menuItem = FavoritesMenuItem(title: "  \(fav.name)", action: playAction)
            menuItem.target = self
            
            menuItem.image = itemImageFunction(fav)
            menuItem.image?.size = menuItemCoverArtImageSize
            
            menuItem.favorite = fav
            menu.addItem(menuItem)
        }
    }
    
    // When a "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: FavoritesMenuItem) {
        
        if let fav = sender.favorite {
            favorites.playFavorite(fav)
        }
    }
}

class FavoriteTracksMenuController: GenericFavoritesMenuController {
    
    override var favoritesFunction: () -> [Favorite] {
        {favorites.allFavoriteTracks}
    }
    
    override var itemImageFunction: (Favorite) -> NSImage? {
        {fav in (fav as? FavoriteTrack)?.track.art?.downscaledOrOriginalImage ?? .imgPlayedTrack}
    }
}

// MARK: Favorite Groups menu --------------------------------------------

//class FavoriteArtistsMenuController: GenericFavoritesMenuController {
//    
//    override var favoritesFunction: () -> [Favorite] {
//        {favorites.allFavoriteArtists}
//    }
//    
//    override var itemImageFunction: (Favorite) -> NSImage? {
//        {_ in .imgArtistGroup_menu}
//    }
//}
//
//class FavoriteAlbumsMenuController: GenericFavoritesMenuController {
//    
//    override var favoritesFunction: () -> [Favorite] {
//        {favorites.allFavoriteAlbums}
//    }
//    
//    override var itemImageFunction: (Favorite) -> NSImage? {
//        
//        {fav in
//            
////            if let favAlbum = fav as? FavoriteGroup {
////                return (libraryDelegate.findGroup(named: favAlbum.groupName, ofType: .album) as? AlbumGroup)?.art ?? .imgAlbumGroup_menu
////            }
//            
//            return .imgAlbumGroup_menu
//        }
//    }
//}
//
//class FavoriteGenresMenuController: GenericFavoritesMenuController {
//    
//    override var favoritesFunction: () -> [Favorite] {
//        {favorites.allFavoriteGenres}
//    }
//    
//    override var itemImageFunction: (Favorite) -> NSImage? {
//        {_ in .imgGenreGroup}
//    }
//}
//
//class FavoriteDecadesMenuController: GenericFavoritesMenuController {
//    
//    override var favoritesFunction: () -> [Favorite] {
//        {favorites.allFavoriteDecades}
//    }
//    
//    override var itemImageFunction: (Favorite) -> NSImage? {
//        {_ in .imgDecadeGroup}
//    }
//}

class FavoriteFoldersMenuController: GenericFavoritesMenuController {
    
    override var favoritesFunction: () -> [Favorite] {
        {favorites.allFavoriteFolders}
    }
    
    override var itemImageFunction: (Favorite) -> NSImage? {
        {_ in .imgFileSystem}
    }
}

class FavoritePlaylistFilesMenuController: GenericFavoritesMenuController {
    
    override var favoritesFunction: () -> [Favorite] {
        {favorites.allFavoritePlaylistFiles}
    }
    
    override var itemImageFunction: (Favorite) -> NSImage? {
        {_ in .imgPlaylist}
    }
}

class FavoritesMenuItem: NSMenuItem {
    
    var favorite: Favorite!
}
