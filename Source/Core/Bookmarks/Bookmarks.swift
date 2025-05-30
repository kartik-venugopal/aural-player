//
//  Bookmarks.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate allowing access to the list of user-defined bookmarks.
///
/// Acts as a middleman between the UI and the Bookmarks list,
/// providing a simplified interface / facade for the UI layer to manipulate the Bookmarks list.
///
/// - SeeAlso: `Bookmark`
///
class Bookmarks: BookmarksProtocol {
    
    typealias Bookmarks = UserManagedObjects<Bookmark>
    
    let bookmarks: Bookmarks
    
    // Delegate used to perform CRUD on the playlist
    private let playQueue: PlayQueueProtocol
    
    // Delegate used to perform playback
    private let player: PlayerProtocol
    
    init(_ playQueue: PlayQueueProtocol, _ player: PlayerProtocol) {
        
        self.playQueue = playQueue
        self.player = player
        
        self.bookmarks = Bookmarks(systemDefinedObjects: [], userDefinedObjects: [])
    }
    
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) -> Bookmark {
        
        let newBookmark = Bookmark(name: name, track: track, startPosition: startPosition, endPosition: endPosition)
        bookmarks.addObject(newBookmark)
        
        Messenger.publish(.Bookmarks.added, payload: newBookmark)
        return newBookmark
    }
    
    var allBookmarks: [Bookmark] {bookmarks.userDefinedObjects}
    
    var count: Int {bookmarks.numberOfUserDefinedObjects}
    
    func getBookmark(named name: String) -> Bookmark? {
        bookmarks.userDefinedObject(named: name)
    }
    
    subscript(_ index: Int) -> Bookmark {
        bookmarks.userDefinedObjects[index]
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        bookmarks.userDefinedObjectExists(named: name)
    }
    
    func playBookmark(_ bookmark: Bookmark) throws {
        
        player.playNow(tracks: [bookmark.track], clearQueue: false,
                       params: PlaybackParams().withStartAndEndPosition(bookmark.startPosition, bookmark.endPosition))
    }
    
    func renameBookmark(named name: String, to newName: String) {
        bookmarks.renameObject(named: name, to: newName)
    }
    
    func deleteBookmarks(atIndices indices: IndexSet) {
        
        let deletedBookmarks = bookmarks.deleteObjects(atIndices: indices)
        Messenger.publish(.Bookmarks.removed, payload: Set(deletedBookmarks))
    }
    
    func deleteBookmarkWithName(_ name: String) {
        
        if let deletedBookmark = bookmarks.deleteObject(named: name) {
            Messenger.publish(.Bookmarks.removed, payload: Set([deletedBookmark]))
        }
    }
    
    var persistentState: BookmarksPersistentState {
        .init(bookmarks: allBookmarks.map {BookmarkPersistentState(bookmark: $0)})
    }
}

extension Bookmarks: TrackRegistryClient {
    
    func updateWithTracksIfPresent(_ tracks: any Sequence<Track>) {
        
        for track in tracks {
            
            bookmarks.updateObjects(matchingPredicate: {bookmark in bookmark.track == track},
                                       updateFunction: {bookmark in bookmark.track = track})
        }
    }
}
