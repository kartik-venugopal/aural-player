//
//  PlayerFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlayerFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var titleStepper: FontSizeStepper!
    @IBOutlet weak var artistAlbumStepper: FontSizeStepper!
    @IBOutlet weak var chapterTitleStepper: FontSizeStepper!
    @IBOutlet weak var seekPositionStepper: FontSizeStepper!
    @IBOutlet weak var feedbackTextStepper: FontSizeStepper!
    
    override var nibName: NSNib.Name? {"PlayerFontScheme"}
    
    func resetFields(_ fontScheme: FontScheme) {
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        let scheme = fontScheme.player
        
        titleStepper.fontSize = scheme.infoBoxTitleFont.pointSize
        artistAlbumStepper.fontSize = scheme.infoBoxArtistAlbumFont.pointSize
        chapterTitleStepper.fontSize = scheme.infoBoxChapterTitleFont.pointSize
        seekPositionStepper.fontSize = scheme.trackTimesFont.pointSize
        feedbackTextStepper.fontSize = scheme.feedbackFont.pointSize
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let fontName = context.textFontName
        
        fontScheme.player.infoBoxTitleFont = NSFont(name: fontName, size: titleStepper.fontSize)!
        fontScheme.player.infoBoxArtistAlbumFont = NSFont(name: fontName, size: artistAlbumStepper.fontSize)!
        fontScheme.player.infoBoxChapterTitleFont = NSFont(name: fontName, size: chapterTitleStepper.fontSize)!
        fontScheme.player.trackTimesFont = NSFont(name: fontName, size: seekPositionStepper.fontSize)!
        fontScheme.player.feedbackFont = NSFont(name: fontName, size: feedbackTextStepper.fontSize)!
    }
}
