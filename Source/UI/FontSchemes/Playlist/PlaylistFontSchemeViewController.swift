//
//  PlaylistFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlaylistFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var trackTextStepper: FontSizeStepper!
    @IBOutlet weak var trackTextYOffsetStepper: NSStepper!
    @IBOutlet weak var txtTrackTextYOffset: NSTextField!
    
    @IBOutlet weak var groupTextStepper: FontSizeStepper!
    @IBOutlet weak var groupTextYOffsetStepper: NSStepper!
    @IBOutlet weak var txtGroupTextYOffset: NSTextField!
    
    @IBOutlet weak var summaryStepper: FontSizeStepper!
    @IBOutlet weak var tabButtonTextStepper: FontSizeStepper!
    
    @IBOutlet weak var chaptersListHeadingStepper: FontSizeStepper!
    @IBOutlet weak var chaptersListHeaderStepper: FontSizeStepper!
    @IBOutlet weak var chaptersListSearchFieldStepper: FontSizeStepper!
    
    override var nibName: NSNib.Name? {"PlaylistFontScheme"}
    
    func resetFields(_ fontScheme: FontScheme) {
        
        scrollView.scrollToTop()
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        let scheme = fontScheme.playlist
        
        trackTextStepper.fontSize = scheme.trackTextFont.pointSize
        
        trackTextYOffsetStepper.integerValue = scheme.trackTextYOffset.roundedInt
        txtTrackTextYOffset.stringValue = String(format: "%d px", trackTextYOffsetStepper.integerValue)
        
        groupTextStepper.fontSize = scheme.groupTextFont.pointSize
        
        groupTextYOffsetStepper.integerValue = scheme.groupTextYOffset.roundedInt
        txtGroupTextYOffset.stringValue = String(format: "%d px", groupTextYOffsetStepper.integerValue)
        
        summaryStepper.fontSize = scheme.summaryFont.pointSize
        tabButtonTextStepper.fontSize = scheme.tabButtonTextFont.pointSize
        
        chaptersListHeadingStepper.fontSize = scheme.chaptersListCaptionFont.pointSize
        chaptersListHeaderStepper.fontSize = scheme.chaptersListHeaderFont.pointSize
        chaptersListSearchFieldStepper.fontSize = scheme.chaptersListSearchFont.pointSize
    }
    
    @IBAction func trackTextYOffsetStepperAction(_ sender: NSStepper) {
        txtTrackTextYOffset.stringValue = String(format: "%d px", trackTextYOffsetStepper.integerValue)
    }
    
    @IBAction func groupTextYOffsetStepperAction(_ sender: NSStepper) {
        txtGroupTextYOffset.stringValue = String(format: "%d px", groupTextYOffsetStepper.integerValue)
    }
   
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontScheme.playlist.trackTextFont = NSFont(name: textFontName, size: trackTextStepper.fontSize)!
        fontScheme.playlist.trackTextYOffset = CGFloat(trackTextYOffsetStepper.integerValue)
        
        fontScheme.playlist.groupTextFont = NSFont(name: textFontName, size: groupTextStepper.fontSize)!
        fontScheme.playlist.groupTextYOffset = CGFloat(groupTextYOffsetStepper.integerValue)
        
        fontScheme.playlist.summaryFont = NSFont(name: textFontName, size: summaryStepper.fontSize)!
        fontScheme.playlist.tabButtonTextFont = NSFont(name: headingFontName, size: tabButtonTextStepper.fontSize)!
        
        fontScheme.playlist.chaptersListHeaderFont = NSFont(name: headingFontName, size: chaptersListHeaderStepper.fontSize)!
        fontScheme.playlist.chaptersListCaptionFont = NSFont(name: headingFontName, size: chaptersListHeadingStepper.fontSize)!
        fontScheme.playlist.chaptersListSearchFont = NSFont(name: textFontName, size: chaptersListSearchFieldStepper.fontSize)!
    }
}
