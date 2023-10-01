//
//  ColorSchemePreviewView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    @IBOutlet weak var playlistSelectedTabButtonCell: PlaylistPreviewTabButtonCell!
    @IBOutlet weak var playlistTabButtonCell: PlaylistPreviewTabButtonCell!
    
    private var playerFunctionButtons: [TintedImageView] = []
    private var playlistIndexDurationLabels: [NSTextField] = []
    private var playlistTrackTitleLabels: [NSTextField] = []
    
    override func awakeFromNib() {
        
        playerFunctionButtons = [btnPlay, btnPreviousTrack, btnNextTrack]
        playerFunctionButtons.forEach {$0.tintFunction = {[weak self] in self?.scheme?.general.functionButtonColor ?? ColorSchemePreset.blackAttack.functionButtonColor}}
        
        playlistIndexDurationLabels = [lblPlaylistIndex_1, lblPlaylistIndex_3, lblPlaylistDuration_1, lblPlaylistDuration_3]
        playlistTrackTitleLabels = [lblPlaylistTitle_1, lblPlaylistTitle_3]
        imgPlayingTrack.tintFunction = {[weak self] in self?.playingTrackIconColor ?? ColorSchemePreset.blackAttack.playlistPlayingTrackIconColor}
        playlistSelectedTabButton.on()
        
        eqSliders = [eqSlider_1, eqSlider_2, eqSlider_3, eqSlider_4, eqSlider_5]
        eqSliderCells = [eqSliderCell_1, eqSliderCell_2, eqSliderCell_3, eqSliderCell_4, eqSliderCell_5]
        
        btnBypass.tintFunction = {[weak self] in self?.activeUnitColor ?? ColorSchemePreset.blackAttack.effectsActiveUnitStateColor}
    }
    
    // When any of the following fields is set, update the corresponding fields.
    
    var scheme: ColorScheme? {
        
        didSet {
            
            if let theScheme = scheme {
                
                backgroundColor = theScheme.general.backgroundColor
                
                playerTitleColor = theScheme.player.trackInfoPrimaryTextColor
                playerArtistAlbumColor = theScheme.player.trackInfoSecondaryTextColor
                
                seekSliderCell.foregroundStartColor = theScheme.player.sliderForegroundColor
                
                switch theScheme.player.sliderForegroundGradientType {
                    
                case .none:
                    
                    seekSliderCell.foregroundEndColor = theScheme.player.sliderForegroundColor
                    
                case .darken:
                    
                    let amount = theScheme.player.sliderForegroundGradientAmount
                    seekSliderCell.foregroundEndColor = seekSliderCell.foregroundStartColor.darkened(CGFloat(amount))
                    
                case .brighten:
                    
                    let amount = theScheme.player.sliderForegroundGradientAmount
                    seekSliderCell.foregroundEndColor = seekSliderCell.foregroundStartColor.brightened(CGFloat(amount))
                }
                
                let endColor = theScheme.player.sliderBackgroundColor
                seekSliderCell.backgroundEndColor = endColor
                
                switch theScheme.player.sliderBackgroundGradientType {
                    
                case .none:
                    
                    seekSliderCell.backgroundStartColor = endColor
                    
                case .darken:
                    
                    let amount = theScheme.player.sliderBackgroundGradientAmount
                    seekSliderCell.backgroundStartColor = endColor.darkened(CGFloat(amount))
                    
                case .brighten:
                    
                    let amount = theScheme.player.sliderBackgroundGradientAmount
                    seekSliderCell.backgroundStartColor = endColor.brightened(CGFloat(amount))
                }
                
                seekSliderCell._knobColor = theScheme.player.sliderKnobColorSameAsForeground ? theScheme.player.sliderForegroundColor : theScheme.player.sliderKnobColor
                
                seekSlider.redraw()
                playerFunctionButtons.forEach {$0.reTint()}
                
                eqSliderCells.forEach {
                    
                    $0.foregroundStartColor = theScheme.effects.activeUnitStateColor
                    
                    switch theScheme.effects.sliderForegroundGradientType {
                        
                    case .none:
                        
                        $0.foregroundEndColor = theScheme.effects.activeUnitStateColor
                        
                    case .darken:
                        
                        let amount = theScheme.effects.sliderForegroundGradientAmount
                        $0.foregroundEndColor = $0.foregroundStartColor.darkened(CGFloat(amount))
                        
                    case .brighten:
                        
                        let amount = theScheme.effects.sliderForegroundGradientAmount
                        $0.foregroundEndColor = $0.foregroundStartColor.brightened(CGFloat(amount))
                    }
                    
                    let endColor = theScheme.effects.sliderBackgroundColor
                    $0.backgroundEndColor = endColor
                    
                    switch theScheme.effects.sliderBackgroundGradientType {
                        
                    case .none:
                        
                        $0.backgroundStartColor = endColor
                        
                    case .darken:
                        
                        let amount = theScheme.effects.sliderBackgroundGradientAmount
                        $0.backgroundStartColor = endColor.darkened(CGFloat(amount))
                        
                    case .brighten:
                        
                        let amount = theScheme.effects.sliderBackgroundGradientAmount
                        $0.backgroundStartColor = endColor.brightened(CGFloat(amount))
                    }
                    
                    $0._knobColor = theScheme.effects.sliderKnobColorSameAsForeground ? theScheme.effects.activeUnitStateColor : theScheme.effects.sliderKnobColor
                }
                
                eqSliders.forEach {$0.redraw()}
                
                activeUnitColor = theScheme.effects.activeUnitStateColor
                effectsCaptionColor = theScheme.general.mainCaptionTextColor
                
                playlistTrackTitleColor = theScheme.playlist.trackNameTextColor
                playlistTrackIndexDurationColor = theScheme.playlist.indexDurationTextColor
                playlistSelectedTrackTitleColor = theScheme.playlist.trackNameSelectedTextColor
                playlistSelectedDurationColor = theScheme.playlist.indexDurationSelectedTextColor
                playlistSelectionBoxColor = theScheme.playlist.selectionBoxColor
                playingTrackIconColor = theScheme.playlist.playingTrackIconColor
                
                playlistSelectedTabButtonCell._selectionBoxColor = theScheme.general.selectedTabButtonColor
                playlistSelectedTabButtonCell.selectedTabButtonTextColor = theScheme.general.selectedTabButtonTextColor
                
                playlistTabButtonCell.tabButtonTextColor = theScheme.general.tabButtonTextColor
                
                [playlistTabButton, playlistSelectedTabButton].forEach {$0?.redraw()}
                
                [playlistBox, playerBox, effectsBox].forEach {$0.show()}
            }
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
            imgPlayingTrack.reTint()
        }
    }
    
    var activeUnitColor: NSColor = .green75Percent {
        
        didSet {
            btnBypass.reTint()
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
    
    var foregroundStartColor: NSColor = NSColor.white
    var foregroundEndColor: NSColor = NSColor.white
    
    var backgroundStartColor: NSColor = NSColor.gray
    var backgroundEndColor: NSColor = NSColor.gray
    
    var _knobColor: NSColor = NSColor.white
    
    override var backgroundGradient: NSGradient {NSGradient(starting: backgroundStartColor, ending: backgroundEndColor)!}
    override var foregroundGradient: NSGradient {NSGradient(starting: foregroundStartColor, ending: foregroundEndColor)!}
    override var knobColor: NSColor {_knobColor}
}

class EQSliderPreviewCell: EQSliderCell {
    
    var foregroundStartColor: NSColor = NSColor.white
    var foregroundEndColor: NSColor = NSColor.white
    
    var backgroundStartColor: NSColor = NSColor.gray
    var backgroundEndColor: NSColor = NSColor.gray
    
    var _knobColor: NSColor = NSColor.white
    
    override var foregroundGradient: NSGradient {
        NSGradient(starting: foregroundStartColor, ending: foregroundEndColor)!
    }
    
    override var backgroundGradient: NSGradient {
        NSGradient(starting: backgroundStartColor, ending: backgroundEndColor)!
    }
    
    override var knobColor: NSColor {_knobColor}
}

class EQSliderConstantColorPreviewCell: EQSliderCell {
    
    override var foregroundGradient: NSGradient {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveSliderGradient
            
        case .bypassed: return Colors.Effects.defaultBypassedSliderGradient
            
        case .suppressed:   return Colors.Effects.defaultSuppressedSliderGradient
            
        }
    }
    
    override var backgroundGradient: NSGradient {
        Colors.Effects.defaultSliderBackgroundGradient
    }
    
    override var knobColor: NSColor {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveUnitColor
            
        case .bypassed: return Colors.Effects.defaultBypassedUnitColor
            
        case .suppressed:   return Colors.Effects.defaultSuppressedUnitColor
            
        }
    }
}

class PlaylistPreviewTabButtonCell: PlaylistViewsButtonCell {
    
    var tabButtonTextColor: NSColor = NSColor.white
    var selectedTabButtonTextColor: NSColor = NSColor.white
    var _selectionBoxColor: NSColor = .white15Percent
    
    override var unselectedTextColor: NSColor {tabButtonTextColor}
    override var selectedTextColor: NSColor {selectedTabButtonTextColor}
    override var selectionBoxColor: NSColor {_selectionBoxColor}
    
    override var textFont: NSFont {_textFont}
    var _textFont: NSFont = .largeTabButtonFont
    
    override var boldTextFont: NSFont {_boldTextFont}
    var _boldTextFont: NSFont = .largeTabButtonFont
    
    override var yOffset: CGFloat {1}
}
