//
//  PlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for playback sequencing controls (repeat/shuffle).
    Also handles sequencing requests from app menus.
 */
class PlayerSequencingViewController: NSViewController, Destroyable {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    let sequencer: SequencerDelegateProtocol = objectGraph.sequencerDelegate
    
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    var offStateTintFunction: TintFunction {{.gray}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    var onStateTintFunction: TintFunction {{.white}}
    
    lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeat, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeat, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffle, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffle, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        
        initSubscriptions()
    }
    
    func initSubscriptions() {}
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        toggleRepeatMode()
    }
    
    func toggleRepeatMode() {
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        toggleShuffleMode()
    }
    
    func toggleShuffleMode() {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(repeatMode))
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(shuffleMode))
    }
    
    func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
    
    func applyTheme() {
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        redrawButtons()
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        redrawButtons()
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
        redrawButtons()
    }
    
    func redrawButtons() {
        [btnRepeat, btnShuffle].forEach {$0.reTint()}
    }
}
