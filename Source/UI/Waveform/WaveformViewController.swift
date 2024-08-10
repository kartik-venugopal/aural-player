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
    
    @IBOutlet weak var lblLeftChannel: NSTextField!
    @IBOutlet weak var lblRightChannel: NSTextField!
    
    @IBOutlet weak var waveformViewLeadingConstraint: NSLayoutConstraint!
    
    lazy var messenger: Messenger = .init(for: self)
    
    lazy var seekTimer: RepeatingTaskExecutor = RepeatingTaskExecutor(intervalMillis: 250,
                                                                      task: {[weak self] in
                                                                        self?.updateProgress()},
                                                                      queue: .main)
    
    var appeared: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblLeftChannel, lblRightChannel])
        
        messenger.subscribe(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .Player.playbackStateChanged, handler: updateForCurrentPlaybackState)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: updateProgress)
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        
        waveformView.prepareToDisappear()
        seekTimer.pause()
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        waveformView.prepareToAppear()
        updateForTrack(playbackInfoDelegate.playingTrack)
    }
    
    override func destroy() {
        
        waveformView.destroy()
        messenger.unsubscribeFromAll()
    }
    
    private func updateProgress() {
        waveformView.progress = playbackInfoDelegate.seekPosition.percentageElapsed / 100.0
    }
    
    private func updateChannelLabels() {
        
        if let track = playbackInfoDelegate.playingTrack,
           let audioFormat = track.playbackContext?.audioFormat {
            
            let isMono: Bool = audioFormat.channelCount < 2
            
            [lblLeftChannel, lblRightChannel].forEach {
                $0?.hideIf(isMono)
            }
            
            // Resize the view
            waveformViewLeadingConstraint.constant = isMono ? 15 : 35
            
        } else {
            
            // No playing track
            [lblLeftChannel, lblRightChannel].forEach {$0?.show()}
            waveformViewLeadingConstraint.constant = 35
        }
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let window = view.window, window.isVisible {
            updateForTrack(notification.endTrack)
        }
    }
    
    private func updateForTrack(_ track: Track?) {
        
        waveformView.audioFile = track?.file
        updateForCurrentPlaybackState()
        updateProgress()
        updateChannelLabels()
    }
    
    private func updateForCurrentPlaybackState() {
        
        if playbackInfoDelegate.state == .playing {
            seekTimer.startOrResume()
        } else {
            seekTimer.pause()
        }
    }
}

extension WaveformViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        [lblCaption, lblLeftChannel, lblRightChannel].forEach {
            $0.font = systemFontScheme.captionFont
        }
    }
}

extension WaveformViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        [lblLeftChannel, lblRightChannel].forEach {
            $0?.textColor = systemColorScheme.secondaryTextColor
        }
    }
}
