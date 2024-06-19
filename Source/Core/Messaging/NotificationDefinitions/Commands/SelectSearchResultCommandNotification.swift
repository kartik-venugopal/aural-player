////
////  SelectSearchResultCommandNotification.swift
////  Aural
////
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
//import Foundation
//
/////
///// Command from the playlist search dialog to the playlist, to show (i.e. select) a specific search result within the playlist.
/////
//class SelectSearchResultCommandNotification: PlaylistCommandNotification {
//
//    // Encapsulates information about the search result (eg. row index)
//    // that helps the playlist locate the result.
//    let searchResult: SearchResult
//
//    init(searchResult: SearchResult, viewSelector: PlaylistViewSelector) {
//
//        self.searchResult = searchResult
//        super.init(notificationName: .playlist_selectSearchResult, viewSelector: viewSelector)
//    }
//}
