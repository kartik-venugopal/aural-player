//
//  PlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for playback sequencing controls (repeat/shuffle).
    Also handles sequencing requests from app menus.
 */
class PlayerSequencingViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    fileprivate let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    fileprivate let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    fileprivate var offStateTintFunction: TintFunction {{.gray}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    fileprivate var onStateTintFunction: TintFunction {{.white}}
    
    override func viewDidLoad() {
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        
        initSubscriptions()
    }
    
    fileprivate func initSubscriptions() {}
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    fileprivate func setRepeatMode(_ repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(repeatMode))
    }
    
    fileprivate func setShuffleMode(_ shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(shuffleMode))
    }
    
    fileprivate func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
}

class WindowedModePlayerSequencingViewController: PlayerSequencingViewController {
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    override fileprivate var offStateTintFunction: TintFunction {{Colors.toggleButtonOffStateColor}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    override fileprivate var onStateTintFunction: TintFunction {{Colors.functionButtonColor}}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        redrawButtons()
    }
    
    override fileprivate func initSubscriptions() {
        
        Messenger.subscribe(self, .player_setRepeatMode, self.setRepeatMode(_:))
        Messenger.subscribe(self, .player_setShuffleMode, self.setShuffleMode(_:))
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, self.changeToggleButtonOffStateColor(_:))
    }
    
    private func applyTheme() {
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        redrawButtons()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func redrawButtons() {
        [btnRepeat, btnShuffle].forEach {$0.reTint()}
    }
}

class MenuBarModePlayerSequencingViewController: PlayerSequencingViewController {
    
    override fileprivate func initSubscriptions() {}
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    override fileprivate var offStateTintFunction: TintFunction {{Colors.Constants.white40Percent}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    override fileprivate var onStateTintFunction: TintFunction {{Colors.Constants.white70Percent}}
}
