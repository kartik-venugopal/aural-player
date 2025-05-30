//
//  PlaylistViewController+ContextMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension PlaylistViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let atLeastOneRowSelected = selectedRowCount >= 1
        let oneRowSelected = selectedRowCount == 1
        
        var playingTrackSelected = false
        if let currentTrackIndex = playQueue.currentTrackIndex, selectedRows.contains(currentTrackIndex) {
            playingTrackSelected = true
        }
        
        playNowMenuItem.showIf(oneRowSelected && (!playingTrackSelected))
        
        [favoriteMenuItem, infoMenuItem].forEach {
            $0.showIf(oneRowSelected)
        }
        
        playNextMenuItem.showIf(atLeastOneRowSelected && player.state.isPlayingOrPaused && !playingTrackSelected)
        
        // TODO: playlist names menu should have a separate delegate so that the menu
        // is not unnecessarily updated until required.
        
        playlistNamesMenu.items.removeAll()
        
        for playlist in playlistsManager.userDefinedObjects {
            playlistNamesMenu.addItem(withTitle: playlist.name, action: #selector(copyTracksToPlaylistAction(_:)), keyEquivalent: "")
        }
        
        // Update the state of the favorites menu items (based on if the clicked track / group is already in the favorites list or not)
        guard let theClickedTrack = selectedTracks.first else {return}
        
        let clickedPlayingTrack = player.playingTrack == theClickedTrack
        let clickedPlayingTrackAndHasChapters = clickedPlayingTrack && theClickedTrack.hasChapters
        
        [moveTracksUpMenuItem, moveTracksDownMenuItem, moveTracksToTopMenuItem, moveTracksToBottomMenuItem].forEach {
            $0?.showIf(atLeastOneRowSelected)
        }
        
        let titlePrefix = favorites.favoriteExists(track: theClickedTrack) ? "Remove" : "Add"
        favoriteTrackMenuItem.title = "\(titlePrefix) this track"
        
        if let artist = theClickedTrack.artist {
            
            let titlePrefix = favorites.favoriteExists(artist: artist) ? "Remove" : "Add"
            favoriteArtistMenuItem.title = "\(titlePrefix) artist '\(artist)'"
            favoriteArtistMenuItem.show()
            
        } else {
            favoriteArtistMenuItem.hide()
        }
        
        if let album = theClickedTrack.album {
            
            let titlePrefix = favorites.favoriteExists(album: album) ? "Remove" : "Add"
            favoriteAlbumMenuItem.title = "\(titlePrefix) album '\(album)'"
            favoriteAlbumMenuItem.show()
            
        } else {
            favoriteAlbumMenuItem.hide()
        }
        
        if let genre = theClickedTrack.genre {
            
            let titlePrefix = favorites.favoriteExists(genre: genre) ? "Remove" : "Add"
            favoriteGenreMenuItem.title = "\(titlePrefix) genre '\(genre)'"
            favoriteGenreMenuItem.show()
            
        } else {
            favoriteGenreMenuItem.hide()
        }
        
        if let decade = theClickedTrack.decade {
            
            let titlePrefix = favorites.favoriteExists(decade: decade) ? "Remove" : "Add"
            favoriteDecadeMenuItem.title = "\(titlePrefix) decade '\(decade)'"
            favoriteDecadeMenuItem.show()
            
        } else {
            favoriteDecadeMenuItem.hide()
        }
    }
    
    @IBAction func viewChaptersListAction(_ sender: Any) {
        windowLayoutsManager.showWindow(withId: .chaptersList)
    }
    
    @IBAction func jumpToChapterAction(_ sender: ChapterMenuItem) {
        messenger.publish(.Player.playChapter, payload: sender.index)
    }
    
    @IBAction func playNowAction(_ sender: NSMenuItem) {
        playSelectedTrack()
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        messenger.publish(.PlayQueue.playNext)
    }
    
    @IBAction func copyTracksToPlaylistAction(_ sender: NSMenuItem) {
        messenger.publish(CopyTracksToPlaylistCommand(tracks: selectedTracks, destinationPlaylistName: sender.title))
    }
    
    @IBAction func createPlaylistWithTracksAction(_ sender: NSMenuItem) {
        messenger.publish(.playlists_createPlaylistFromTracks, payload: selectedTracks)
    }
    
    @IBAction func removeTracksMenuAction(_ sender: Any) {
        messenger.publish(.PlayQueue.removeTracks)
    }
    
    @IBAction func cropSelectionMenuAction(_ sender: Any) {
        messenger.publish(.PlayQueue.cropSelection)
    }
    
    @IBAction func moveTracksUpMenuAction(_ sender: Any) {
        messenger.publish(.PlayQueue.moveTracksUp)
    }
    
    @IBAction func moveTracksDownMenuAction(_ sender: Any) {
        messenger.publish(.PlayQueue.moveTracksDown)
    }
    
    @IBAction func moveTracksToTopMenuAction(_ sender: Any) {
        messenger.publish(.PlayQueue.moveTracksToTop)
    }

    @IBAction func moveTracksToBottomMenuAction(_ sender: Any) {
        messenger.publish(.PlayQueue.moveTracksToBottom)
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoriteTrackAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first else {return}

        if favoriteTrackMenuItem.isOn {

            // Remove from Favorites list and display notification
            favorites.removeFavorite(track: theClickedTrack)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Track removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favorites.addFavorite(track: theClickedTrack)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Track added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoriteArtistAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let artist = theClickedTrack.artist else {return}

        if favoriteArtistMenuItem.isOn {

            // Remove from Favorites list and display notification
            favorites.removeFavorite(artist: artist)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Artist removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favorites.addFavorite(artist: artist)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Artist added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
    }
    
    @IBAction func favoriteAlbumAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let album = theClickedTrack.album else {return}

        if favoriteAlbumMenuItem.isOn {

            // Remove from Favorites list and display notification
            favorites.removeFavorite(album: album)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Album removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favorites.addFavorite(album: album)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Album added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
    }
    
    @IBAction func favoriteGenreAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let genre = theClickedTrack.genre else {return}

        if favoriteGenreMenuItem.isOn {

            // Remove from Favorites list and display notification
            favorites.removeFavorite(genre: genre)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Genre removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favorites.addFavorite(genre: genre)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Genre added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
    }
    
    @IBAction func favoriteDecadeAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let decade = theClickedTrack.decade else {return}

        if favoriteDecadeMenuItem.isOn {

            // Remove from Favorites list and display notification
            favorites.removeFavorite(decade: decade)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Decade removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favorites.addFavorite(decade: decade)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Decade added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func trackInfoAction(_ sender: AnyObject) {
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        guard let selectedTrack = selectedTracks.first else {return}
                
        trackReader.loadAuxiliaryMetadata(for: selectedTrack)
        TrackInfoViewContext.displayedTrack = selectedTrack
        
        // TODO: This assumes Modular mode, make generic
        if windowLayoutsManager.isWindowLoaded(withId: .trackInfo) {
            messenger.publish(.Player.trackInfo_refresh)
        }
        
        windowLayoutsManager.showWindow(withId: .trackInfo)
    }
    
    // Shows the selected tracks in Finder.
    @IBAction func showInFinderAction(_ sender: NSMenuItem) {
        URL.showInFinder(selectedTracks.map {$0.file})
    }
}
