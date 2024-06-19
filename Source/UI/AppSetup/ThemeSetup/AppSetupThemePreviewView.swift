//
//  AppSetupThemePreviewView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class AppSetupThemePreviewView: NSView {
    
    @IBOutlet weak var playerBox: NSBox!
    
    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblArtistAlbum: NSTextField!
    @IBOutlet weak var lblDuration: NSTextField!
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: AppSetupSeekSliderPreviewCell!
    
    @IBOutlet weak var btnPlay: TintedImageView!
    @IBOutlet weak var btnPreviousTrack: TintedImageView!
    @IBOutlet weak var btnNextTrack: TintedImageView!
    
    private var playerButtons: [TintedImageView] = []
    
    override func awakeFromNib() {
        
        playerButtons = [btnPlay, btnPreviousTrack, btnNextTrack]
//        playerButtons.forEach {$0.contentTintColor = self.colorScheme?.buttonColor ?? ColorScheme.defaultScheme.buttonColor}
        
//        playlistIndexDurationLabels = [lblPlaylistIndex_1, lblPlaylistIndex_3, lblPlaylistDuration_1, lblPlaylistDuration_3]
//        playlistTrackTitleLabels = [lblPlaylistTitle_1, lblPlaylistTitle_3]
//        imgPlayingTrack.tintFunction = {[weak self] in self?.playingTrackIconColor ?? ColorSchemePreset.blackAttack.playlistPlayingTrackIconColor}
//        playlistSelectedTabButton.on()
//
//        eqSliders = [eqSlider_1, eqSlider_2, eqSlider_3, eqSlider_4, eqSlider_5]
//        eqSliderCells = [eqSliderCell_1, eqSliderCell_2, eqSliderCell_3, eqSliderCell_4, eqSliderCell_5]
//
//        btnBypass.tintFunction = {[weak self] in self?.activeUnitColor ?? ColorSchemePreset.blackAttack.effectsActiveUnitStateColor}
    }
    
    // When any of the following fields is set, update the corresponding fields.
    
    var colorScheme: ColorScheme? {
        
        didSet {
            
            guard let theScheme = colorScheme else {return}
            
            backgroundColor = theScheme.backgroundColor
            
            playerTitleColor = theScheme.primaryTextColor
            playerArtistAlbumColor = theScheme.secondaryTextColor
            playerDurationColor = theScheme.tertiaryTextColor
            
            seekSliderCell._foregroundColor = theScheme.activeControlColor
            seekSliderCell._backgroundColor = theScheme.inactiveControlColor
            seekSlider.redraw()
            
            playerButtons.forEach {$0.contentTintColor = theScheme.buttonColor}
        }
    }
    
    var fontScheme: FontScheme? {
        
        didSet {
            
            guard let theScheme = fontScheme else {return}
            
            lblTrackTitle.font = theScheme.prominentFont
            lblArtistAlbum.font = theScheme.normalFont
            lblDuration.font = theScheme.smallFont
        }
    }
    
    var backgroundColor: NSColor = NSColor.black {
        
        didSet {
            playerBox.fillColor = backgroundColor
        }
    }
    
    var playerTitleColor: NSColor = NSColor.white {
        
        didSet {
            
            lblTrackTitle.textColor = playerTitleColor
            imgArt.contentTintColor = playerTitleColor
            playerBox.borderColor = playerTitleColor
        }
    }
    
    var playerArtistAlbumColor: NSColor = NSColor.white {
        
        didSet {
            lblArtistAlbum.textColor = playerArtistAlbumColor
        }
    }
    
    var playerDurationColor: NSColor = NSColor.white {
        
        didSet {
            lblDuration.textColor = playerDurationColor
        }
    }
    
    var activeUnitColor: NSColor = .green75Percent {
        
        didSet {
            seekSlider.redraw()
        }
    }
}

class AppSetupSeekSliderPreviewCell: SeekSliderCell {
    
    var _foregroundColor: NSColor = NSColor.white
    var _backgroundColor: NSColor = NSColor.gray
    
    override var controlStateColor: NSColor {
        _foregroundColor
    }
    
    override var backgroundColor: NSColor {
        _backgroundColor
    }
}
