//
//  TuneBrowserGlobals.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

let tuneBrowserMusicFolderURL: URL = {
    
    if let volumeName = System.primaryVolumeName {
        return URL(fileURLWithPath: "/Volumes/\(volumeName)\(NSHomeDirectory())/Music")
    } else {
        return FilesAndPaths.musicDir
    }
}()

let tuneBrowserPrimaryVolumeURL: URL = {
    
    if let volumeName = System.primaryVolumeName {
        return URL(fileURLWithPath: "/Volumes/\(volumeName)")
    } else {
        return URL(fileURLWithPath: "/")
    }
}()

//let tuneBrowserSidebarMusicFolder: TuneBrowserSidebarItem = TuneBrowserSidebarItem(url: tuneBrowserMusicFolderURL)
