//
//  BookmarkNameInputReceiver.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A StringInputReceiver that receives, validates, and saves, the name of a new bookmark as input from a user (through a StringInputPopover).
 */
class BookmarkNameInputReceiver: StringInputReceiver {
    
    private lazy var bookmarks: BookmarksDelegateProtocol = ObjectGraph.bookmarksDelegate
    
    var inputPrompt: String {
        return "Enter a bookmark name:"
    }
    
    var defaultValue: String? {
        return BookmarkContext.defaultBookmarkName
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !bookmarks.bookmarkWithNameExists(string)
        return valid ? (true, nil) : (false, "A bookmark with this name already exists !")
    }
    
    // Receives a new bookmark name and saves the new bookmark
    func acceptInput(_ string: String) {
        
        if let track = BookmarkContext.bookmarkedTrack, let startPosition = BookmarkContext.bookmarkedTrackStartPosition {
            
            // Track position
            _ = bookmarks.addBookmark(string, track, startPosition, BookmarkContext.bookmarkedTrackEndPosition)
        }
    }
}

/* This class is used as a temporary holder of bookmark information when a popover is displayed to the user to obtain a name for a new bookmark. This is required because the info may change as the track continues playing.
 
    TODO: What if the track changes (i.e. user didn't confirm the prompt in time) ? The popover should be dimissed. Verify that this does indeed happen.
 */
class BookmarkContext {
    
    // Changes whenever a bookmark is added
    static var bookmarkedTrack: Track?
    static var bookmarkedTrackStartPosition: Double?
    static var bookmarkedTrackEndPosition: Double?  // This will be non-nil only if/when a loop is being bookmarked
    static var defaultBookmarkName: String?
}
