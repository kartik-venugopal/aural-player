//
//  Playlist.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A facade for all operations pertaining to the playlist. Delegates operations to the underlying
/// playlists (flat and grouping/hierarchical), and aggregates results from those operations.
///
class Playlist: TrackList, PlaylistProtocol, UserManagedObject {
    
    override var displayName: String {"The playlist '\(name)'"}
    
    var name: String
    
    let dateCreated: Date
    
    private var persistentStateToLoad: PlaylistPersistentState? = nil
    
    var key: String {

        get {name}
        set {name = newValue}
    }

    let userDefined: Bool = true
    
    private lazy var messenger: Messenger = Messenger(for: self)

    init(name: String) {
        
        self.name = name
        self.dateCreated = Date()
    }
    
    init?(persistentState: PlaylistPersistentState) {
        
        guard let name = persistentState.name else {return nil}
        
        self.name = name
        self.dateCreated = persistentState.dateCreated ?? Date()
        
        super.init()
        
        if let files = persistentState.tracks, files.isNonEmpty {
            loadTracks(from: files)
        }
    }
    
    override func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let indices = super.insertTracks(newTracks, at: insertionIndex)
        messenger.publish(PlaylistTracksAddedNotification(playlistName: name, trackIndices: indices))
        return indices
    }
    
    override func preTrackLoad() {
        messenger.publish(.playlist_startedAddingTracks)
    }
    
    override func postTrackLoad() {
        
        // Now that the tracks have been loaded into the playlist, invalidate
        // and release the persistent state.
        persistentStateToLoad = nil
        
        messenger.publish(.playlist_doneAddingTracks, payload: name)
    }
    
    override func postBatchLoad(indices: IndexSet) {
        messenger.publish(PlaylistTracksAddedNotification(playlistName: name, trackIndices: indices))
    }
}

extension Playlist: Equatable {
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.name == rhs.name
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PlaylistPersistentState {
        persistentStateToLoad ?? PlaylistPersistentState(name: name, tracks: tracks.map {$0.file}, dateCreated: dateCreated)
    }
}
