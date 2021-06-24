//
//  PlayerFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlayerFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var titleStepper: NSStepper!
    @IBOutlet weak var txtTitle: NSTextField!
    
    @IBOutlet weak var artistAlbumStepper: NSStepper!
    @IBOutlet weak var txtArtistAlbum: NSTextField!
    
    @IBOutlet weak var chapterTitleStepper: NSStepper!
    @IBOutlet weak var txtChapterTitle: NSTextField!
    
    @IBOutlet weak var seekPositionStepper: NSStepper!
    @IBOutlet weak var txtSeekPosition: NSTextField!
    
    @IBOutlet weak var feedbackTextStepper: NSStepper!
    @IBOutlet weak var txtFeedbackText: NSTextField!
    
    override var nibName: NSNib.Name? {return "PlayerFontScheme"}
    
    var fontSchemesView: NSView {
        self.view
    }
    
    func resetFields(_ fontScheme: FontScheme) {
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        titleStepper.floatValue = Float(fontScheme.player.infoBoxTitleFont.pointSize * 10)
        txtTitle.stringValue = String(format: "%.1f", titleStepper.floatValue / 10.0)
        
        artistAlbumStepper.floatValue = Float(fontScheme.player.infoBoxArtistAlbumFont.pointSize * 10)
        txtArtistAlbum.stringValue = String(format: "%.1f", artistAlbumStepper.floatValue / 10.0)
        
        chapterTitleStepper.floatValue = Float(fontScheme.player.infoBoxChapterTitleFont.pointSize * 10)
        txtChapterTitle.stringValue = String(format: "%.1f", chapterTitleStepper.floatValue / 10.0)
        
        seekPositionStepper.floatValue = Float(fontScheme.player.trackTimesFont.pointSize * 10)
        txtSeekPosition.stringValue = String(format: "%.1f", seekPositionStepper.floatValue / 10.0)
        
        feedbackTextStepper.floatValue = Float(fontScheme.player.feedbackFont.pointSize * 10)
        txtFeedbackText.stringValue = String(format: "%.1f", feedbackTextStepper.floatValue / 10.0)
    }
    
    @IBAction func titleStepperAction(_ sender: NSStepper) {
        txtTitle.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func artistAlbumStepperAction(_ sender: NSStepper) {
        txtArtistAlbum.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chapterTitleStepperAction(_ sender: NSStepper) {
        txtChapterTitle.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func seekPositionStepperAction(_ sender: NSStepper) {
        txtSeekPosition.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
  
    @IBAction func feedbackTextStepperAction(_ sender: NSStepper) {
        txtFeedbackText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let textFontName = context.textFontName
        
        fontScheme.player.infoBoxTitleFont = NSFont(name: textFontName, size: CGFloat(titleStepper.floatValue / 10.0))!
        fontScheme.player.infoBoxArtistAlbumFont = NSFont(name: textFontName, size: CGFloat(artistAlbumStepper.floatValue / 10.0))!
        fontScheme.player.infoBoxChapterTitleFont = NSFont(name: textFontName, size: CGFloat(chapterTitleStepper.floatValue / 10.0))!
        fontScheme.player.trackTimesFont = NSFont(name: textFontName, size: CGFloat(seekPositionStepper.floatValue / 10.0))!
        fontScheme.player.feedbackFont = NSFont(name: textFontName, size: CGFloat(feedbackTextStepper.floatValue / 10.0))!
    }
}
