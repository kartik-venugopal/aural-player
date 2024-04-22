//
//  BookmarksDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// TODO: Refactor this to BookmarksManager: UserManagedObjects<Bookmark>

///
/// A delegate allowing access to the list of user-defined bookmarks.
///
/// Acts as a middleman between the UI and the Bookmarks list,
/// providing a simplified interface / facade for the UI layer to manipulate the Bookmarks list.
///
/// - SeeAlso: `Bookmark`
///
class BookmarksDelegate: BookmarksDelegateProtocol {
    
    typealias Bookmarks = UserManagedObjects<Bookmark>
    
    let bookmarks: Bookmarks
    
    // Delegate used to perform CRUD on the playlist
    private let playQueue: PlayQueueDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(_ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.playQueue = playQueue
        self.player = player
        
        self.bookmarks = Bookmarks(systemDefinedObjects: [], userDefinedObjects: [])
    }
    
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) -> Bookmark {
        
        let newBookmark = Bookmark(name: name, track: track, startPosition: startPosition, endPosition: endPosition)
        bookmarks.addObject(newBookmark)
        
        messenger.publish(.Bookmarks.added, payload: newBookmark)
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
        
        playQueueDelegate.enqueueToPlayNow(tracks: [bookmark.track], clearQueue: false,
                                           params: PlaybackParams().withStartAndEndPosition(bookmark.startPosition, bookmark.endPosition))
    }
    
    func renameBookmark(named name: String, to newName: String) {
        bookmarks.renameObject(named: name, to: newName)
    }
    
    func deleteBookmarks(atIndices indices: IndexSet) {
        
        let deletedBookmarks = bookmarks.deleteObjects(atIndices: indices)
        messenger.publish(.Bookmarks.removed, payload: Set(deletedBookmarks))
    }
    
    func deleteBookmarkWithName(_ name: String) {
        
        if let deletedBookmark = bookmarks.deleteObject(named: name) {
            messenger.publish(.Bookmarks.removed, payload: Set([deletedBookmark]))
        }
    }
    
    var persistentState: BookmarksPersistentState {
        .init(bookmarks: allBookmarks.map {BookmarkPersistentState(bookmark: $0)})
    }
}
