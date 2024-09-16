//
// ChaptersListNotifications.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension Notification.Name {
    
    struct ChaptersList {
        
        // Commands the chapters list to initiate playback of the selected chapter
        static let playSelectedChapter = Notification.Name("chaptersList_playSelectedChapter")
    }
}
