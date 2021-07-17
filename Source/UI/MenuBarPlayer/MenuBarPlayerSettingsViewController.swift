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
    private let player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
    
    override func viewWillAppear() {
        
        btnShowArt.onIf(MenuBarPlayerViewState.showAlbumArt)
        btnShowArtist.onIf(MenuBarPlayerViewState.showArtist)
        btnShowAlbum.onIf(MenuBarPlayerViewState.showAlbum)
        
        btnShowChapterTitle.showIf(player.playingTrack?.hasChapters ?? false)
        btnShowChapterTitle.onIf(MenuBarPlayerViewState.showCurrentChapter)
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSButton) {
        
        MenuBarPlayerViewState.showAlbumArt.toggle()
        [imgArt, artOverlayBox].forEach {$0.showIf(MenuBarPlayerViewState.showAlbumArt && player.state.isPlayingOrPaused)}

        // Arrange the views in the following Z-order, with the settings box frontmost.
        
        if MenuBarPlayerViewState.showAlbumArt {
            artOverlayBox.bringToFront()
        }
        
        infoBox.bringToFront()
        settingsBox.bringToFront()
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSButton) {
        
        MenuBarPlayerViewState.showArtist.toggle()
        trackInfoView.update()
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSButton) {
        
        MenuBarPlayerViewState.showAlbum.toggle()
        trackInfoView.update()
    }
    
    @IBAction func showOrHideChapterTitleAction(_ sender: NSButton) {
        
        MenuBarPlayerViewState.showCurrentChapter.toggle()
        trackInfoView.update()
    }
}
