//
//  ArtistsPlaylistViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Artists" playlist view
 */
class ArtistsPlaylistViewController: GroupingPlaylistViewController {
    
    override var groupType: GroupType {.artist}
    override var playlistType: PlaylistType {.artists}
    
    override var nibName: String? {"Artists"}
}
