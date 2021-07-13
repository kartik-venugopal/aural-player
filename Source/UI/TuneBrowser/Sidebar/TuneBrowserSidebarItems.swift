//
//  TuneBrowserSidebarItems.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

enum TuneBrowserSidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    case volumes = "Volumes"
    case folders = "Folders"
    
    var description: String {rawValue}
}

class TuneBrowserSidebarItem: Equatable {
    
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    static func == (lhs: TuneBrowserSidebarItem, rhs: TuneBrowserSidebarItem) -> Bool {
        lhs.url == rhs.url
    }
}
