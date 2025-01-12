//
//  PlaylistsManager.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Manages the collection of all playlists - the default playlist and all user-defined playlists (if any).
///
class PlaylistsManager: UserManagedObjects<Playlist>, PersistentModelObject {
    
    // Keeps track of how many playlists have been initialized so far, upon app startup.
    private var playlistAddOpsCount: AtomicIntCounter = AtomicIntCounter()

    private lazy var messenger = Messenger(for: self)
    
    private var playlistsLoaded: Bool = false
    
    var isAnyPlaylistBeingModified: Bool {
        userDefinedObjects.contains(where: {$0.isBeingModified})
    }
    
    var playlistNames: [String] {
        userDefinedObjects.map {$0.name}
    }

    init() {
        
        super.init(systemDefinedObjects: [], userDefinedObjects: [])
        
        messenger.subscribe(to: .Application.launched, handler: loadPlaylists)
        messenger.subscribe(to: .playlist_startedAddingTracks, handler: playlistStartedAddingTracks)
        messenger.subscribe(to: .playlist_doneAddingTracks, handler: playlistDoneAddingTracks)
    }
    
    @discardableResult func createNewPlaylist(named name: String) -> Playlist {
        
        let newPlaylist = Playlist(name: name)
        
        addObject(newPlaylist)
        return newPlaylist
    }
    
    @discardableResult func duplicatePlaylist(_ originalPlaylist: Playlist, withName nameOfDuplicate: String) -> Playlist {
        
        let newPlaylist = Playlist(name: nameOfDuplicate)
        newPlaylist.addTracks(originalPlaylist.tracks)
        
        addObject(newPlaylist)
        return newPlaylist
    }
    
    // MARK: Notification handling ---------------------------------------------------------------
    
    func loadPlaylists() {
        
        // TODO: This should only be done if/when the library is also built. Use the same conditions here.
        
        if playlistsLoaded {return}
        
        playlistsLoaded = true
        
        guard let state = appPersistentState.playlists?.playlists else {return}
        
        for playlistState in state {
            
            if let playlist = Playlist(persistentState: playlistState) {
                addObject(playlist)
            }
        }
    }
    
    private func playlistStartedAddingTracks() {
        
        playlistAddOpsCount.increment()
        
        // The first (of potentially multiple) playlist track load operation has begun.
        if playlistAddOpsCount.value == 1 {
            messenger.publish(.playlists_startedAddingTracks)
        }
    }
    
    private func playlistDoneAddingTracks() {
        
        playlistAddOpsCount.decrement()

        // All playlists have finished track load operations.
        if playlistAddOpsCount.isZero {
            messenger.publish(.playlists_doneAddingTracks)
        }
    }

    var persistentState: PlaylistsPersistentState {
        PlaylistsPersistentState(playlists: userDefinedObjects.map {$0.persistentState})
    }
}
