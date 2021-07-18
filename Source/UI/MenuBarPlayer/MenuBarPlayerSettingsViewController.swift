//
//  MenuBarPlayerSettingsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MenuBarPlayerSettingsViewController: NSViewController {
    
    @IBOutlet weak var btnShowArt: NSButton!
    @IBOutlet weak var btnShowArtist: NSButton!
    @IBOutlet weak var btnShowAlbum: NSButton!
    @IBOutlet weak var btnShowChapterTitle: NSButton!
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var trackInfoView: MenuBarPlayingTrackTextView!
    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var artOverlayBox: NSBox!
    
    @IBOutlet weak var settingsBox: NSBox!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private lazy var player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
    
    private lazy var uiState: MenuBarPlayerUIState = objectGraph.menuBarPlayerUIState
    
    override func viewWillAppear() {
        
        btnShowArt.onIf(uiState.showAlbumArt)
        btnShowArtist.onIf(uiState.showArtist)
        btnShowAlbum.onIf(uiState.showAlbum)
        
        btnShowChapterTitle.showIf(player.playingTrack?.hasChapters ?? false)
        btnShowChapterTitle.onIf(uiState.showCurrentChapter)
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSButton) {
        
        uiState.showAlbumArt.toggle()
        [imgArt, artOverlayBox].forEach {$0.showIf(uiState.showAlbumArt && player.state.isPlayingOrPaused)}

        // Arrange the views in the following Z-order, with the settings box frontmost.
        
        if uiState.showAlbumArt {
            artOverlayBox.bringToFront()
        }
        
        infoBox.bringToFront()
        settingsBox.bringToFront()
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSButton) {
        
        uiState.showArtist.toggle()
        trackInfoView.update()
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSButton) {
        
        uiState.showAlbum.toggle()
        trackInfoView.update()
    }
    
    @IBAction func showOrHideChapterTitleAction(_ sender: NSButton) {
        
        uiState.showCurrentChapter.toggle()
        trackInfoView.update()
    }
}
