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
        
        messenger.subscribe(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .Player.playbackStateChanged, handler: updateForCurrentPlaybackState)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: updateProgress)
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        print("Disappearing ...")
        seekTimer.pause()
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        print("Appearing ...")
        
        updateForTrack(playbackInfoDelegate.playingTrack)
    }
    
    override func destroy() {
        
        waveformView.destroy()
        messenger.unsubscribeFromAll()
    }
    
    private func updateProgress() {
        waveformView.progress = playbackInfoDelegate.seekPosition.percentageElapsed / 100.0
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let window = view.window, window.isVisible {
            updateForTrack(notification.endTrack)
        } else {
            print("Not updating WaveformView. Window: \(view.window), \(view.window?.isVisible)")
        }
    }
    
    private func updateForTrack(_ track: Track?) {
        
        waveformView.audioFile = track?.file
        updateForCurrentPlaybackState()
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
        lblCaption.font = systemFontScheme.captionFont
    }
}

extension WaveformViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
}
