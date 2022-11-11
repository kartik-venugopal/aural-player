//
//  BookmarkNameInputReceiver.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A StringInputReceiver that receives, validates, and saves, the name of a new bookmark as input from a user (through a StringInputPopover).
 */
class BookmarkNameInputReceiver: StringInputReceiver {
    
    private lazy var bookmarks: BookmarksDelegateProtocol = objectGraph.bookmarksDelegate
    
    private static let inputPromptString: String = "Enter a bookmark name:"
    
    var context: BookmarkInputContext?
    
    var inputPrompt: String {
        Self.inputPromptString
    }
    
    var defaultValue: String? {
        context?.defaultName
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !bookmarks.bookmarkWithNameExists(string)
        return valid ? (true, nil) : (false, "A bookmark with this name already exists !")
    }
    
    // Receives a new bookmark name and saves the new bookmark.
    func acceptInput(_ string: String) {
        
        if let track = context?.track, let startPosition = context?.startPosition {
            _ = bookmarks.addBookmark(string, track, startPosition, context?.endPosition)
        }
    }
}

/*
    This struct is used as a temporary holder of bookmark information when a popover is displayed to the user to obtain a name for a new bookmark. This is required because the info may change as the track continues playing.
 */
struct BookmarkInputContext {
    
    let track: Track?
    let startPosition: Double?
    let endPosition: Double?  // This will be non-nil only if/when a loop is being bookmarked.
    let defaultName: String?
}
