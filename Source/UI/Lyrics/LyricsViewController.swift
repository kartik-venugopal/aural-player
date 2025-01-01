//
// LyricsViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit
import LyricsCore

class LyricsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Lyrics"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var textView: NSTextView!
    
    private var track: Track?
    private var lyrics: Lyrics?
    private var curLine: LyricsLine?
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.wantsLayer = true
        
//        if appModeManager.currentMode == .modular,
//           
//            let lblCaptionLeadingConstraint = lblCaption.superview?.constraints.first(where: {$0.firstAttribute == .leading}) {
//            lblCaptionLeadingConstraint.constant = 23
//        }
        
        fontSchemeChanged()
        colorSchemeChanged()
        changeCornerRadius(playerUIState.cornerRadius)
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        updateForTrack(playbackInfoDelegate.playingTrack)
    }
    
    private func updateForTrack(_ track: Track?) {
        
        self.track = track
        self.lyrics = track?.fetchLocalLyrics()
        
        updateLyricsText()
    }
    
    private func updateLyricsText() {
        
        textView.string = ""
        guard let lyrics else {return}
        
        for line in lyrics.lines {
            
//            let pos = line.position
//            let maxPos = line.maxPosition
            
            appendString(text: line.content, font: systemFontScheme.prominentFont, color: systemColorScheme.secondaryTextColor, lineSpacing: 20)
        }
    }
    
    private func appendString(text: String, font: NSFont, color: NSColor, lineSpacing: CGFloat? = nil) {
        
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let style = NSMutableParagraphStyle()
        var str: String = text
        
        style.alignment = .left
        
        if let spacing = lineSpacing {
            
            // If lineSpacing is specified, add a paragraph style attribute and set its lineSpacing field.
            style.lineSpacing = spacing
            
            // Add a newline character to the text to create a line break
            str += "\n"
        }
        
        attributes[.paragraphStyle] = style
        
        textView.textStorage?.append(NSAttributedString(string: str, attributes: attributes))
    }
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        updateForTrack(notif.endTrack)
    }
    
    func changeCornerRadius(_ radius: CGFloat) {
//        rootContainerBox.cornerRadius = radius
        view.layer?.cornerRadius = radius
    }
}

extension LyricsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        updateLyricsText()
    }
}

extension LyricsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {

        view.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        textView.backgroundColor = systemColorScheme.backgroundColor
        updateLyricsText()
    }
}
