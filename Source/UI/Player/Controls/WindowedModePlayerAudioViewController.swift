//
//  WindowedModePlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlayerAudioViewController: PlayerAudioViewController {
    
    override var showsPanControl: Bool {true}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    override func initSubscriptions() {
        
        // Subscribe to notifications
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
        
        Messenger.subscribe(self, .player_muteOrUnmute, self.muteOrUnmute)
        Messenger.subscribe(self, .player_decreaseVolume, self.decreaseVolume(_:))
        Messenger.subscribe(self, .player_increaseVolume, self.increaseVolume(_:))
        
        Messenger.subscribe(self, .player_panLeft, self.panLeft)
        Messenger.subscribe(self, .player_panRight, self.panRight)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .player_changeSliderColors, self.changeSliderColors)
        Messenger.subscribe(self, .player_changeSliderValueTextColor, self.changeSliderValueTextColor(_:))
    }
    
    // Decreases the volume by a certain preset decrement
    func decreaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.decreaseVolume(inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    func increaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.increaseVolume(inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        [lblVolume, lblPan, lblPanCaption, lblPanCaption2].forEach {$0.font = fontSchemesManager.systemScheme.player.feedbackFont}
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)   // This call will also take care of toggle buttons.
        changeSliderColors()
        changeSliderValueTextColor(scheme.player.sliderValueTextColor)
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        
        btnVolume.reTint()
        
        lblPanCaption.textColor = color
        lblPanCaption2.textColor = color
    }
    
    private func changeSliderColors() {
        [volumeSlider, panSlider].forEach({$0?.redraw()})
    }
    
    private func changeSliderValueTextColor(_ color: NSColor) {
        
        lblVolume.textColor = Colors.Player.feedbackTextColor
        lblPan.textColor = Colors.Player.feedbackTextColor
    }
}
