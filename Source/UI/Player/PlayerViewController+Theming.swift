//
//  PlayerViewController+Theming.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension PlayerViewController: ThemeInitialization {
    
    @objc func initTheme() {
        
        updateTrackTextViewFontsAndColors()
        
        lblPlaybackPosition.font = playbackPositionFont
        lblPlaybackPosition.textColor = playbackPositionColor
        
        lblVolume.font = volumeLevelFont
        lblVolume.textColor = volumeLevelColor
        
        artViewTintColorChanged(systemColorScheme.secondaryTextColor)
        
        [btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward].forEach {
            $0?.colorChanged(systemColorScheme.buttonColor)
        }
        
        btnVolume.colorChanged(systemColorScheme.buttonColor)
        
        seekSlider.redraw()
        volumeSlider.redraw()
    }
    
    @objc func setUpTheming() {
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObservers(self)
        
        setUpColorSchemePropertyObservation()
    }
    
    @objc func updateTrackTextViewFontsAndColors() {
        // To be overriden!
    }
    
    @objc func updateMultilineTrackTextViewFontsAndColors() {
        
        multilineTrackTextView.titleFont = multilineTrackTextTitleFont
        multilineTrackTextView.artistAlbumFont = multilineTrackTextArtistAlbumFont
        multilineTrackTextView.chapterTitleFont = multilineTrackTextChapterTitleFont
        
        multilineTrackTextView.backgroundColor = systemColorScheme.backgroundColor
        multilineTrackTextView.titleColor = multilineTrackTextTitleColor
        multilineTrackTextView.artistAlbumColor = multilineTrackTextArtistAlbumColor
        multilineTrackTextView.chapterTitleColor = multilineTrackTextChapterTitleColor
        
        multilineTrackTextView.update()
    }
    
    @objc func updateScrollingTrackTextViewFontsAndColors() {
        
        scrollingTrackTextView.font = scrollingTrackTextFont
        scrollingTextViewContainerBox.fillColor = systemColorScheme.backgroundColor
        scrollingTrackTextView.titleTextColor = scrollingTrackTextTitleColor
        scrollingTrackTextView.artistTextColor = scrollingTrackTextArtistColor
        
        layoutScrollingTrackTextView()
        scrollingTrackTextView.update()
    }
}

extension PlayerViewController: FontSchemeObserver {
    
    @objc func fontSchemeChanged() {
        
        updateTrackTextViewFonts()
        lblPlaybackPosition.font = playbackPositionFont
        lblVolume.font = volumeLevelFont
    }
    
    @objc func updateTrackTextViewFonts() {
        // To be overriden!
    }
    
    @objc func updateMultilineTrackTextViewFonts() {
        
        multilineTrackTextView.titleFont = multilineTrackTextTitleFont
        multilineTrackTextView.artistAlbumFont = multilineTrackTextArtistAlbumFont
        multilineTrackTextView.chapterTitleFont = multilineTrackTextChapterTitleFont
        
        multilineTrackTextView.update()
    }
    
    @objc func updateScrollingTrackTextViewFonts() {
        
        scrollingTrackTextView.font = scrollingTrackTextFont
        layoutScrollingTrackTextView()
    }
}

extension PlayerViewController: ColorSchemeObserver {
    
    @objc func colorSchemeChanged() {
        
        updateTrackTextViewColors()
        
        artViewTintColorChanged(systemColorScheme.secondaryTextColor)
        
        lblPlaybackPosition.textColor = playbackPositionColor
        
        [btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward].forEach {
            $0?.colorChanged(systemColorScheme.buttonColor)
        }
        
        btnVolume.colorChanged(systemColorScheme.buttonColor)
        
        seekSlider.redraw()
        volumeSlider.redraw()
        lblVolume.textColor = volumeLevelColor
    }
    
    @objc func setUpColorSchemePropertyObservation() {
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: volumeSlider)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, changeReceivers: [seekSlider, volumeSlider])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, changeReceivers: [seekSlider, volumeSlider])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward, btnVolume].compactMap {$0})
    }
    
    @objc func updateTrackTextViewColors() {
        // To be overriden!
    }
    
    @objc func updateMultilineTrackTextViewColors() {
        
        multilineTrackTextView.backgroundColor = systemColorScheme.backgroundColor
        multilineTrackTextView.titleColor = multilineTrackTextTitleColor
        multilineTrackTextView.artistAlbumColor = multilineTrackTextArtistAlbumColor
        multilineTrackTextView.chapterTitleColor = multilineTrackTextChapterTitleColor
        
        multilineTrackTextView.update()
    }
    
    @objc func updateScrollingTrackTextViewColors() {
        
        scrollingTextViewContainerBox.fillColor = systemColorScheme.backgroundColor
        scrollingTrackTextView.titleTextColor = scrollingTrackTextTitleColor
        scrollingTrackTextView.artistTextColor = scrollingTrackTextArtistColor
        scrollingTrackTextView.update()
    }
    
    @objc func artViewTintColorChanged(_ newColor: NSColor) {
        
        // Re-tint the default playing track cover art, if no track cover art is displayed.
        if playbackDelegate.playingTrack?.art == nil {
            artView.contentTintColor = newColor
        }
    }
}
