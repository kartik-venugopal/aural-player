//
//  LibraryHoverControlsBox.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryHoverControlsBox: NSBox {
    
    @IBOutlet weak var btnPlay: TintedImageButton!
    @IBOutlet weak var btnEnqueueAndPlay: TintedImageButton!
    @IBOutlet weak var btnRepeat: TintedImageButton!
    @IBOutlet weak var btnShuffle: TintedImageButton!
    @IBOutlet weak var btnFavorite: TintedImageButton!
    
    fileprivate lazy var buttons: [TintedImageButton] = [btnPlay, btnEnqueueAndPlay, btnRepeat, btnShuffle, btnFavorite]
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    var group: Group? {
        
        didSet {
            
            guard let groupName = group?.name else {return}
            
            btnPlay.toolTip = "Play '\(groupName)'"
            btnEnqueueAndPlay.toolTip = "Enqueue and play '\(groupName)'"
            btnRepeat.toolTip = "Repeat '\(groupName)'"
            btnShuffle.toolTip = "Shuffle '\(groupName)'"
            btnFavorite.toolTip = "Add '\(groupName)' to Favorites"   // TODO: Toggle between Add / Remove
        }
    }
    
    var playlist: ImportedPlaylist? {
        
        didSet {
            
            guard let playlistName = playlist?.displayName else {return}
            
            btnPlay.toolTip = "Play '\(playlistName)'"
            btnEnqueueAndPlay.toolTip = "Enqueue and play '\(playlistName)'"
            btnRepeat.toolTip = "Repeat '\(playlistName)'"
            btnShuffle.toolTip = "Shuffle '\(playlistName)'"
            btnFavorite.toolTip = "Add '\(playlistName)' to Favorites"   // TODO: Toggle between Add / Remove
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fillColor = NSColor(white: 0.35, alpha: 0.8)
        cornerRadius = 5
    }
    
    @IBAction func playGroupOrPlaylistAction(_ sender: NSButton) {
        
        messenger.publish(RepeatAndShuffleModesCommandNotification(repeatMode: .off, shuffleMode: .off))
        doPlay(clearPlayQueue: true)
    }
    
    @IBAction func enqueueAndPlayGroupAction(_ sender: NSButton) {
        doPlay(clearPlayQueue: false)
    }
    
    @IBAction func repeatGroupAction(_ sender: NSButton) {
        
        messenger.publish(RepeatAndShuffleModesCommandNotification(repeatMode: .all, shuffleMode: .off))
        doPlay(clearPlayQueue: true)
    }
    
    @IBAction func shuffleGroupAction(_ sender: NSButton) {
        
        messenger.publish(RepeatAndShuffleModesCommandNotification(repeatMode: .off, shuffleMode: .on))
        doPlay(clearPlayQueue: true)
    }
    
    @IBAction func addToFavoritesAction(_ sender: NSButton) {
        
        if let group = self.group {
            
            switch group.type {
                
            case .artist:
                favoritesDelegate.addFavorite(artist: group.name)
                
            case .album:
                favoritesDelegate.addFavorite(album: group.name)
                
            case .genre:
                favoritesDelegate.addFavorite(genre: group.name)
                
            case .decade:
                favoritesDelegate.addFavorite(decade: group.name)
                
//            case .albumDisc:
                
            default:
                break
            }
            
            return
        }
        
//        if let playlistFile
    }
    
    private func doPlay(clearPlayQueue: Bool) {
        
        if let group = self.group {
            playQueue.enqueueToPlayNow(group: group, clearQueue: clearPlayQueue)
        }
        
        if let playlist = self.playlist {
            playQueue.enqueueToPlayNow(playlistFile: playlist, clearQueue: clearPlayQueue)
        }
    }
}
