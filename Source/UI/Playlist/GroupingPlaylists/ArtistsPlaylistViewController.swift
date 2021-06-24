//
//  ArtistsPlaylistViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Artists" playlist view
 */
class ArtistsPlaylistViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .artist}
    override internal var playlistType: PlaylistType {return .artists}
    
    override var nibName: String? {"Artists"}
}
