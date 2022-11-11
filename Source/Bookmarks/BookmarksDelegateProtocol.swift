//
//  BookmarksDelegateProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate allowing access to the list of user-defined bookmarks.
///
/// Acts as a middleman between the UI and the Bookmarks list,
/// providing a simplified interface / facade for the UI layer to manipulate the Bookmarks list.
///
/// - SeeAlso: `Bookmark`
///
protocol BookmarksDelegateProtocol {

    // If the endPosition parameter is nil, it means a single track position is being bookmarked. Otherwise, a loop is being bookmarked.
    func addBookmark(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double?) -> Bookmark
    
    var allBookmarks: [Bookmark] {get}
    
    var count: Int {get}
    
    func getBookmarkAtIndex(_ index: Int) -> Bookmark
    
    func getBookmark(named name: String) -> Bookmark?
    
    func renameBookmark(named name: String, to newName: String)
    
    func deleteBookmarks(atIndices indices: IndexSet)
    
    func deleteBookmarkWithName(_ name: String)
    
    func bookmarkWithNameExists(_ name: String) -> Bool
    
    func playBookmark(_ bookmark: Bookmark) throws
}
