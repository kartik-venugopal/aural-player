//
//  FavoritesHoverControlBox.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoritesContainerView: MouseTrackingView {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var hoverControls: FavoritesHoverControlsBox!
    
    var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoriteTrack(atChronologicalIndex: row)}
    }
    
    override func mouseMoved(with event: NSEvent) {

        super.mouseMoved(with: event)
        
        // Show hover controls box (overlay).
        
        let row = tableView.row(at: tableView.convert(event.locationInWindow, from: nil))
        
        guard row >= 0,
              let rowView = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) else {
            
            hoverControls.hide()
            return
        }
        
        hoverControls.favorite = favoriteAtRowFunction(row)
        
        let boxHeight = hoverControls.height / 2
        let rowHeight = rowView.height / 2
        
        let conv = self.convert(NSMakePoint(rowView.frame.maxX, rowView.frame.minY + rowHeight - boxHeight), from: rowView)
        hoverControls.setFrameOrigin(NSMakePoint(tableView.frame.centerX, conv.y))
        hoverControls.show()
        hoverControls.bringToFront()
    }
    
    override func mouseExited(with event: NSEvent) {
        
        super.mouseExited(with: event)
        hoverControls.hide()
    }
    
    override func viewDidHide() {
        
        super.viewDidHide()
        hoverControls.hide()
    }
}

class FavoriteArtistsContainerView: FavoritesContainerView {
    
    override var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoriteArtist(atChronologicalIndex: row)}
    }
}

class FavoriteAlbumsContainerView: FavoritesContainerView {
    
    override var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoriteAlbum(atChronologicalIndex: row)}
    }
}

class FavoriteGenresContainerView: FavoritesContainerView {
    
    override var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoriteGenre(atChronologicalIndex: row)}
    }
}

class FavoriteDecadesContainerView: FavoritesContainerView {
    
    override var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoriteDecade(atChronologicalIndex: row)}
    }
}

class FavoriteFoldersContainerView: FavoritesContainerView {
    
    override var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoriteFolder(atChronologicalIndex: row)}
    }
}

class FavoritePlaylistFilesContainerView: FavoritesContainerView {
    
    override var favoriteAtRowFunction: (Int) -> Favorite? {
        {row in favoritesDelegate.favoritePlaylistFile(atChronologicalIndex: row)}
    }
}

class FavoritesHoverControlsBox: NSBox {
    
    @IBOutlet weak var btnPlay: TintedImageButton!
    @IBOutlet weak var btnEnqueueAndPlay: TintedImageButton!
    @IBOutlet weak var btnFavorite: TintedImageButton!
    
    fileprivate lazy var buttons: [TintedImageButton] = [btnPlay, btnEnqueueAndPlay, btnFavorite]
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    var favorite: Favorite? {
        
        didSet {
            
            guard let favorite = self.favorite else {return}
            
            btnPlay.toolTip = "Play '\(favorite.name)'"
            btnEnqueueAndPlay.toolTip = "Enqueue '\(favorite.name)'"
            btnFavorite.toolTip = "Remove '\(favorite.name)' from Favorites"
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fillColor = NSColor(white: 0.35, alpha: 0.8)
        cornerRadius = 5
    }
    
    @IBAction func playFavoriteAction(_ sender: NSButton) {
        
        if let favorite = self.favorite {
            favoritesDelegate.playFavorite(favorite)
        }
    }
    
    @IBAction func enqueueAndPlayFavoriteAction(_ sender: NSButton) {
        
        if let favorite = self.favorite {
            favoritesDelegate.enqueueFavorite(favorite)
        }
    }
    
    @IBAction func deleteFromFavoritesAction(_ sender: NSButton) {
        
        if let favorite = self.favorite {
            
            favoritesDelegate.removeFavorite(favorite)
            messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([favorite]))
            self.hide()
        }
    }
}
