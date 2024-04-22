//
//  ThemePreviewView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View that gives the user a visual preview of what the UI would look like if a particular theme is applied to it.
 */
class ThemePreviewView: NSView {
    
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
    @IBOutlet weak var lblEffectsCaption: NSTextField!
    
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
        
//        playerFunctionButtons = [btnPlay, btnPreviousTrack, btnNextTrack]
//        playerFunctionButtons.forEach {$0.tintFunction = {[weak self] in self?.theme?.colorScheme.buttonColor ?? ColorSchemePreset.blackAttack.functionButtonColor}}
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
    
    var theme: Theme? = nil
//
//        didSet {
//
//            if let colorScheme = theme?.colorScheme, let fontScheme = theme?.fontScheme {
//
//                backgroundColor = colorScheme.backgroundColor
//
//                playerTitleColor = colorScheme.player.trackInfoPrimaryTextColor
//                playerArtistAlbumColor = colorScheme.player.trackInfoSecondaryTextColor
//
//                seekSliderCell.foregroundStartColor = colorScheme.player.sliderForegroundColor
//
//                switch colorScheme.player.sliderForegroundGradientType {
//
//                case .none:
//
//                    seekSliderCell.foregroundEndColor = colorScheme.player.sliderForegroundColor
//
//                case .darken:
//
//                    let amount = colorScheme.player.sliderForegroundGradientAmount
//                    seekSliderCell.foregroundEndColor = seekSliderCell.foregroundStartColor.darkened(CGFloat(amount))
//
//                case .brighten:
//
//                    let amount = colorScheme.player.sliderForegroundGradientAmount
//                    seekSliderCell.foregroundEndColor = seekSliderCell.foregroundStartColor.brightened(CGFloat(amount))
//                }
//
//                let endColor = colorScheme.player.inactiveControlColor
//                seekSliderCell.backgroundEndColor = endColor
//
//                switch colorScheme.player.sliderBackgroundGradientType {
//
//                case .none:
//
//                    seekSliderCell.backgroundStartColor = endColor
//
//                case .darken:
//
//                    let amount = colorScheme.player.sliderBackgroundGradientAmount
//                    seekSliderCell.backgroundStartColor = endColor.darkened(CGFloat(amount))
//
//                case .brighten:
//
//                    let amount = colorScheme.player.sliderBackgroundGradientAmount
//                    seekSliderCell.backgroundStartColor = endColor.brightened(CGFloat(amount))
//                }
//
//                seekSliderCell._knobColor = colorScheme.player.sliderKnobColorSameAsForeground ? colorScheme.player.sliderForegroundColor : colorScheme.player.sliderKnobColor
//
//                seekSlider.redraw()
//                playerFunctionButtons.forEach {$0.reTint()}
//
//                eqSliderCells.forEach({
//
//                    $0.foregroundStartColor = colorScheme.activeControlColor
//
//                    switch colorScheme.effects.sliderForegroundGradientType {
//
//                    case .none:
//
//                        $0.foregroundEndColor = colorScheme.activeControlColor
//
//                    case .darken:
//
//                        let amount = colorScheme.effects.sliderForegroundGradientAmount
//                        $0.foregroundEndColor = $0.foregroundStartColor.darkened(CGFloat(amount))
//
//                    case .brighten:
//
//                        let amount = colorScheme.effects.sliderForegroundGradientAmount
//                        $0.foregroundEndColor = $0.foregroundStartColor.brightened(CGFloat(amount))
//                    }
//
//                    let endColor = colorScheme.effects.inactiveControlColor
//                    $0.backgroundEndColor = endColor
//
//                    switch colorScheme.effects.sliderBackgroundGradientType {
//
//                    case .none:
//
//                        $0.backgroundStartColor = endColor
//
//                    case .darken:
//
//                        let amount = colorScheme.effects.sliderBackgroundGradientAmount
//                        $0.backgroundStartColor = endColor.darkened(CGFloat(amount))
//
//                    case .brighten:
//
//                        let amount = colorScheme.effects.sliderBackgroundGradientAmount
//                        $0.backgroundStartColor = endColor.brightened(CGFloat(amount))
//                    }
//
//                    $0._knobColor = colorScheme.effects.sliderKnobColorSameAsForeground ? colorScheme.activeControlColor : colorScheme.effects.sliderKnobColor
//                })
//
//                eqSliders.forEach {$0.redraw()}
//
//                activeUnitColor = colorScheme.activeControlColor
//                effectsCaptionColor = colorScheme.secondaryTextColor
//
//                playlistTrackTitleColor = colorScheme.playlist.trackNameTextColor
//                playlistTrackIndexDurationColor = colorScheme.playlist.indexDurationTextColor
//                playlistSelectedTrackTitleColor = colorScheme.playlist.trackNameSelectedTextColor
//                playlistSelectedDurationColor = colorScheme.playlist.indexDurationSelectedTextColor
//                playlistSelectionBoxColor = colorScheme.playlist.selectionBoxColor
//                playingTrackIconColor = colorScheme.playlist.playingTrackIconColor
//
//                playlistSelectedTabButtonCell._selectionBoxColor = colorScheme.general.selectedTabButtonColor
//                playlistSelectedTabButtonCell.selectedTabButtonTextColor = colorScheme.general.selectedTabButtonTextColor
//
//                playlistTabButtonCell.tabButtonTextColor = colorScheme.general.tabButtonTextColor
//
//                [playlistTabButton, playlistSelectedTabButton].forEach {$0?.redraw()}
//
//                [playlistBox, playerBox, effectsBox].forEach {$0.show()}
//
//                // MARK: Set fonts
//
//                lblPlayerTrackTitle.font = fontScheme.player.infoBoxTitleFont
//                lblPlayerArtistAlbum.font = fontScheme.player.infoBoxArtistAlbumFont
//
//                playlistTabButtonCell._textFont = fontScheme.playlist.tabButtonTextFont
//                playlistSelectedTabButtonCell._boldTextFont = fontScheme.playlist.tabButtonTextFont
//
//                (playlistIndexDurationLabels + playlistTrackTitleLabels + [lblPlaylistSelectedDuration, lblPlaylistSelectedTitle]).forEach {$0.font = fontScheme.normalFont}
//
//                lblEffectsCaption.font = fontScheme.captionFont
//            }
//
//            if let windowAppearance = theme?.windowAppearance {
//
//                [playerBox, playlistBox, effectsBox].forEach {
//                    $0.cornerRadius = windowAppearance.cornerRadius
//                }
//            }
//        }
//    }
    
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
            lblEffectsCaption.textColor = effectsCaptionColor
        }
    }
    
    func clear() {
        [playlistBox, playerBox, effectsBox].forEach {$0.hide()}
    }
}
