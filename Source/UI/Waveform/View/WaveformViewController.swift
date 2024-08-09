//
//  WaveformViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class WaveformViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Waveform"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var waveformView: WaveformView!
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
        
        messenger.subscribe(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        waveformView.audioFile = notification.endTrack?.file
    }
}

extension WaveformViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        lblCaption.font = systemFontScheme.captionFont
    }
}

extension WaveformViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
//        waveformView.progressColor = sys
    }
}
