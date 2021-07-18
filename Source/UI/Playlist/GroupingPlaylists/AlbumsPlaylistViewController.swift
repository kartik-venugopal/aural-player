//
//  AlbumsPlaylistViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Albums" playlist view
 */
class AlbumsPlaylistViewController: GroupingPlaylistViewController {
    
    override var groupType: GroupType {return .album}
    override var playlistType: PlaylistType {return .albums}
    
    override var nibName: String? {"Albums"}
}
