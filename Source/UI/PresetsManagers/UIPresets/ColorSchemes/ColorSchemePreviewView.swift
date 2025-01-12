//
//  ColorSchemePreviewView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View that gives the user a visual preview of what the UI would look like if a particular color scheme is applied to it.
 */
class ColorSchemePreviewView: NSView {
    
    @IBOutlet weak var playerBox: NSBox!
    @IBOutlet weak var playlistBox: NSBox!
    @IBOutlet weak var effectsBox: NSBox!
    
    @IBOutlet weak var lblPlayerTrackTitle: NSTextField!
    @IBOutlet weak var lblPlayerArtistAlbum: NSTextField!
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderPreviewCell!
    
    @IBOutlet weak var btnPlay: TintedImageView!
    @IBOutlet weak var btnPreviousTrack: TintedImageView!
    @IBOutlet weak var btnNextTrack: TintedImageView!
    
    @IBOutlet weak var lblPlaylistIndex_1: NSTextField!
    @IBOutlet weak var imgPlayingTrack: TintedImageView!
    @IBOutlet weak var lblPlaylistIndex_3: NSTextField!
    
    @IBOutlet weak var lblPlaylistTitle_1: NSTextField!
    @IBOutlet weak var lblPlaylistSelectedTitle: NSTextField!
    @IBOutlet weak var lblPlaylistTitle_3: NSTextField!
    
    @IBOutlet weak var lblPlaylistDuration_1: NSTextField!
    @IBOutlet weak var lblPlaylistSelectedDuration: NSTextField!
    @IBOutlet weak var lblPlaylistDuration_3: NSTextField!
    
    @IBOutlet weak var playlistSelectionBox: NSBox!
    
    @IBOutlet weak var btnBypass: TintedImageView!
    @IBOutlet weak var lblFxCaption: NSTextField!
    
    @IBOutlet weak var eqSlider_1: NSSlider!
    @IBOutlet weak var eqSlider_2: NSSlider!
    @IBOutlet weak var eqSlider_3: NSSlider!
    @IBOutlet weak var eqSlider_4: NSSlider!
    @IBOutlet weak var eqSlider_5: NSSlider!
    
    private var eqSliders: [NSSlider] = []
    private var eqSliderCells: [EQSliderPreviewCell] = []
    
    @IBOutlet weak var eqSliderCell_1: EQSliderPreviewCell!
    @IBOutlet weak var eqSliderCell_2: EQSliderPreviewCell!
    @IBOutlet weak var eqSliderCell_3: EQSliderPreviewCell!
    @IBOutlet weak var eqSliderCell_4: EQSliderPreviewCell!
    @IBOutlet weak var eqSliderCell_5: EQSliderPreviewCell!
    
    @IBOutlet weak var playlistSelectedTabButton: NSButton!
    @IBOutlet weak var playlistTabButton: NSButton!
    
//    @IBOutlet weak var playlistSelectedTabButtonCell: PlaylistPreviewTabButtonCell!
//    @IBOutlet weak var playlistTabButtonCell: PlaylistPreviewTabButtonCell!
    
    private var playerFunctionButtons: [TintedImageView] = []
    private var playlistIndexDurationLabels: [NSTextField] = []
    private var playlistTrackTitleLabels: [NSTextField] = []
    
    override func awakeFromNib() {
        
        playerFunctionButtons = [btnPlay, btnPreviousTrack, btnNextTrack]
//        playerFunctionButtons.forEach {$0.tintFunction = {[weak self] in self?.scheme?.buttonColor ?? ColorSchemePreset.blackAttack.functionButtonColor}}
//
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
    
    var scheme: ColorScheme? {
        
        didSet {
            
            guard let theScheme = scheme else {return}
            
            // MARK: Player
                
                backgroundColor = theScheme.backgroundColor

                playerTitleColor = theScheme.primaryTextColor
                playerArtistAlbumColor = theScheme.secondaryTextColor

                seekSliderCell._foregroundColor = theScheme.activeControlColor
                seekSliderCell._backgroundColor = theScheme.inactiveControlColor

                seekSlider.redraw()
                playerFunctionButtons.forEach {$0.contentTintColor = theScheme.buttonColor}
            
            // MARK: Effects

                eqSliderCells.forEach {

                    $0._foregroundColor = theScheme.activeControlColor
                    $0._backgroundColor = theScheme.inactiveControlColor
                    $0._knobColor = theScheme.activeControlColor
                }

                eqSliders.forEach {$0.redraw()}

                activeUnitColor = theScheme.activeControlColor
                effectsCaptionColor = theScheme.secondaryTextColor
            
            // MARK: Play Queue

//                playlistTrackTitleColor = theScheme.playlist.trackNameTextColor
//                playlistTrackIndexDurationColor = theScheme.playlist.indexDurationTextColor
//                playlistSelectedTrackTitleColor = theScheme.playlist.trackNameSelectedTextColor
//                playlistSelectedDurationColor = theScheme.playlist.indexDurationSelectedTextColor
//                playlistSelectionBoxColor = theScheme.playlist.selectionBoxColor
//                playingTrackIconColor = theScheme.playlist.playingTrackIconColor
//
//                playlistSelectedTabButtonCell._selectionBoxColor = theScheme.general.selectedTabButtonColor
//                playlistSelectedTabButtonCell.selectedTabButtonTextColor = theScheme.general.selectedTabButtonTextColor
//
//                playlistTabButtonCell.tabButtonTextColor = theScheme.general.tabButtonTextColor
//
//                [playlistTabButton, playlistSelectedTabButton].forEach {$0?.redraw()}
//
//                [playlistBox, playerBox, effectsBox].forEach {$0.show()}
//            }
        }
    }
    
    var backgroundColor: NSColor = NSColor.black {
        
        didSet {
            [playerBox, effectsBox, playlistBox].forEach {$0.fillColor = backgroundColor}
        }
    }
    
    var playerTitleColor: NSColor = NSColor.white {
        
        didSet {
            lblPlayerTrackTitle.textColor = playerTitleColor
        }
    }
    
    var playerArtistAlbumColor: NSColor = NSColor.white {
        
        didSet {
            lblPlayerArtistAlbum.textColor = playerArtistAlbumColor
        }
    }
    
    var playlistTrackTitleColor: NSColor = .white70Percent {
        
        didSet {
            playlistTrackTitleLabels.forEach {$0.textColor = playlistTrackTitleColor}
        }
    }
    
    var playlistTrackIndexDurationColor: NSColor = NSColor.gray {
        
        didSet {
            playlistIndexDurationLabels.forEach {$0.textColor = playlistTrackIndexDurationColor}
        }
    }
    
    var playlistSelectedTrackTitleColor: NSColor = NSColor.white {
        
        didSet {
            lblPlaylistSelectedTitle.textColor = playlistSelectedTrackTitleColor
        }
    }
    
    var playlistSelectedDurationColor: NSColor = .white70Percent {
        
        didSet {
            lblPlaylistSelectedDuration.textColor = playlistSelectedDurationColor
        }
    }
    
    var playlistSelectionBoxColor: NSColor = .white15Percent {
        
        didSet {
            playlistSelectionBox.fillColor = playlistSelectionBoxColor
        }
    }
    
    var playingTrackIconColor: NSColor = .green75Percent {
        
        didSet {
//            imgPlayingTrack.reTint()
        }
    }
    
    var activeUnitColor: NSColor = .green75Percent {
        
        didSet {
//            btnBypass.reTint()
        }
    }
    
    var effectsCaptionColor: NSColor = .white50Percent {
        
        didSet {
            lblFxCaption.textColor = effectsCaptionColor
        }
    }
    
    func clear() {
        [playlistBox, playerBox, effectsBox].forEach {$0.hide()}
    }
}

class SeekSliderPreviewCell: SeekSliderCell {
    
    var _foregroundColor: NSColor = NSColor.white
    var _backgroundColor: NSColor = NSColor.gray
    var _knobColor: NSColor = NSColor.white
}

class EQSliderPreviewCell: EQSliderCell {
    
    var _foregroundColor: NSColor = NSColor.white
    var _backgroundColor: NSColor = NSColor.gray
    var _knobColor: NSColor = NSColor.white
}
