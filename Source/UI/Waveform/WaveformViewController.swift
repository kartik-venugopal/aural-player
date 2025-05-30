//
//  WaveformViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class WaveformViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Waveform"}
    
    @IBOutlet weak var waveformView: WaveformView!
    
    @IBOutlet weak var lblLeftChannel: NSTextField!
    @IBOutlet weak var lblLeftChannelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblRightChannel: NSTextField!
    @IBOutlet weak var lblRightChannelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var waveformViewLeadingConstraint: NSLayoutConstraint!
    private static let waveformViewLeadingConstant_mono: CGFloat = 5
    private static let waveformViewLeadingConstant_stereo: CGFloat = 30
    
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
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblLeftChannel, lblRightChannel])
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .Player.playbackStateChanged, handler: updateForCurrentPlaybackState)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: updateProgress)
        messenger.subscribeAsync(to: .Player.playbackLoopChanged, handler: playbackLoopChanged)
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        
        waveformView.prepareToDisappear()
        seekTimer.pause()
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        waveformView.prepareToAppear()
        repositionChannelLabels()
        updateChannelLabels()
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        updateForTrack(player.playingTrack)
    }
    
    override func destroy() {
        
        waveformView.destroy()
        messenger.unsubscribeFromAll()
    }
    
    private func updateProgress() {
        waveformView.progress = player.seekPosition.percentageElapsed / 100.0
    }
    
    ///
    /// Vertical centering with respect to the main Waveform view.
    ///
    private func repositionChannelLabels() {
        
        let verticalMargin = (waveformView.height / 4) - (lblLeftChannel.height / 2)
        
        lblLeftChannelTopConstraint.constant = verticalMargin
        lblRightChannelBottomConstraint.constant = -verticalMargin
        
        view.layoutSubtreeIfNeeded()
    }
    
    private func updateChannelLabels() {
        
        if let track = player.playingTrack,
           let audioFormat = track.playbackContext?.audioFormat {
            
            let isMono: Bool = audioFormat.channelCount < 2
            
            [lblLeftChannel, lblRightChannel].forEach {
                $0?.hideIf(isMono)
            }
            
            // Resize the view
            waveformViewLeadingConstraint.constant = isMono ? Self.waveformViewLeadingConstant_mono : Self.waveformViewLeadingConstant_stereo
            
        } else {
            
            // No playing track
            [lblLeftChannel, lblRightChannel].forEach {$0?.show()}
            waveformViewLeadingConstraint.constant = Self.waveformViewLeadingConstant_stereo
        }
        
        view.layoutSubtreeIfNeeded()
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let window = view.window, window.isVisible {
            updateForTrack(notification.endTrack)
        }
    }
    
    private func playbackLoopChanged() {
        
        if let playingTrack = player.playingTrack, let loop = player.playbackLoop {
            waveformView.loopStartProgress = loop.startTime / playingTrack.duration
            
        } else {
            
            waveformView.loopStartProgress = nil
            return
        }
    }
    
    private func updateForTrack(_ track: Track?) {

        updateChannelLabels()
        waveformView.audioFile = track?.file
        updateForCurrentPlaybackState()
        playbackLoopChanged()
        updateProgress()
    }
    
    private func updateForCurrentPlaybackState() {
        
        if player.isPlaying {
            seekTimer.startOrResume()
        } else {
            seekTimer.pause()
        }
    }
}

extension WaveformViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        [lblLeftChannel, lblRightChannel].forEach {
            $0.font = systemFontScheme.captionFont
        }
    }
}

extension WaveformViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        [lblLeftChannel, lblRightChannel].forEach {
            $0?.textColor = systemColorScheme.secondaryTextColor
        }
    }
}
