//
//  BookmarksDelegate.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
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
class BookmarksDelegate: BookmarksDelegateProtocol {
    
    private typealias Bookmarks = UserManagedObjects<Bookmark>
    
    private let bookmarks: Bookmarks
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: [BookmarkPersistentState]?, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.playlist = playlist
        self.player = player
        
        // Restore the bookmarks model object from persistent state
        let allBookmarks: [Bookmark] = persistentState?.compactMap {Bookmark(persistentState: $0)} ?? []
        self.bookmarks = Bookmarks(systemDefinedObjects: [], userDefinedObjects: allBookmarks)
    }
    
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double? = nil) -> Bookmark {
        
        let newBookmark = Bookmark(name, track.file, startPosition, endPosition)
        bookmarks.addObject(newBookmark)
        
        messenger.publish(.bookmarksList_trackAdded, payload: newBookmark)
        return newBookmark
    }
    
    var allBookmarks: [Bookmark] {bookmarks.userDefinedObjects}
    
    var count: Int {bookmarks.numberOfUserDefinedObjects}
    
    func getBookmark(named name: String) -> Bookmark? {
        bookmarks.userDefinedObject(named: name)
    }
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark {
        bookmarks.userDefinedObjects[index]
    }
    
    func bookmarkWithNameExists(_ name: String) -> Bool {
        bookmarks.userDefinedObjectExists(named: name)
    }
    
    func playBookmark(_ bookmark: Bookmark) throws {
        
        do {
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(bookmark.file) {
            
                // Play it.
                let params = PlaybackParams().withStartAndEndPosition(bookmark.startPosition, bookmark.endPosition)
                player.play(newTrack, params)
            }
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play Bookmark item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    func renameBookmark(named name: String, to newName: String) {
        bookmarks.renameObject(named: name, to: newName)
    }
    
    func deleteBookmarks(atIndices indices: IndexSet) {
        
        let deletedBookmarks = bookmarks.deleteObjects(atIndices: indices)
        messenger.publish(.bookmarksList_tracksRemoved, payload: Set(deletedBookmarks))
    }
    
    func deleteBookmarkWithName(_ name: String) {
        
        if let deletedBookmark = bookmarks.deleteObject(named: name) {
            messenger.publish(.bookmarksList_tracksRemoved, payload: Set([deletedBookmark]))
        }
    }
    
    var persistentState: [BookmarkPersistentState] {
        allBookmarks.map {BookmarkPersistentState(bookmark: $0)}
    }
}
