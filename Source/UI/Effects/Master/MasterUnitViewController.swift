//
//  MasterUnitViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"MasterUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var masterUnitView: MasterUnitView!
    @IBOutlet weak var btnRememberSettings: EffectsUnitToggle!
    @IBOutlet weak var lblRememberSettings: NSTextField!
    
    private lazy var btnRememberSettingsStateMachine: ButtonStateMachine<Bool> = ButtonStateMachine(initialState: false, mappings: [
        ButtonStateMachine.StateMapping(state: false, image: .imgRememberSettings, colorProperty: \.inactiveControlColor, toolTip: "Remember all sound settings for this track"),
        ButtonStateMachine.StateMapping(state: true, image: .imgRememberSettings, colorProperty: \.activeControlColor, toolTip: "Don't remember sound settings for this track"),
      ],
      button: btnRememberSettings)
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var masterUnit: MasterUnitProtocol {audioGraph.masterUnit}
    private var eqUnit: EQUnitProtocol {audioGraph.eqUnit}
    private var pitchShiftUnit: PitchShiftUnitProtocol {audioGraph.pitchShiftUnit}
    private var timeStretchUnit: TimeStretchUnitProtocol {audioGraph.timeStretchUnit}
    private var reverbUnit: ReverbUnitProtocol {audioGraph.reverbUnit}
    private var delayUnit: DelayUnitProtocol {audioGraph.delayUnit}
    private var filterUnit: FilterUnitProtocol {audioGraph.filterUnit}
    
    private let soundProfiles: SoundProfiles = audioGraph.soundProfiles
    
    private let soundPreferences: SoundPreferences = preferences.soundPreferences
    private let playbackPreferences: PlaybackPreferences = preferences.playbackPreferences
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterUnit.presets)
    }
    
    override func initControls() {
        
        super.initControls()
        
        updateSettingsMemoryControls(forTrack: playbackInfoDelegate.playingTrack)
        broadcastStateChangeNotification()
    }
    
    private func updateSettingsMemoryControls(forTrack track: Track?) {
        
        if let theTrack = track {
            
            [btnRememberSettings, lblRememberSettings].forEach {$0?.show()}
            btnRememberSettings.onIf(soundProfiles.hasFor(theTrack))
            
        } else {
            [btnRememberSettings, lblRememberSettings].forEach {$0?.hide()}
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func fuseBoxMenuPopupAction(_ sender: NSButton) {
        
        var location = masterUnitView.btnFuseBoxMenu.frame.origin
        location.y -= 10 // Menu appears below the button
        sender.menu?.popUp(positioning: sender.menu?.item(at: 0), at: location, in: view)
    }
    
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        allEffectsToggled()
    }
    
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        super.presetsAction(sender)
        messenger.publish(.Effects.updateEffectsUnitView, payload: EffectsUnitType.master)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchShiftUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.toggleState()
        
        messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Sound profile for current track.
    @IBAction func rememberSettingsAction(_ sender: AnyObject) {
        
        guard let playingTrack = playQueueDelegate.currentTrack else {return}
        
        let soundProfiles = audioGraph.soundProfiles
        
        if soundProfiles.hasFor(playingTrack) {
            
            messenger.publish(.Effects.deleteSoundProfile)
            btnRememberSettings.off()
            
        } else {
            
            messenger.publish(.Effects.saveSoundProfile)
            btnRememberSettings.on()
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackChanged(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribe(to: .Effects.MasterUnit.allEffectsToggled, handler: allEffectsToggled)
    }
    
    override func stateChanged() {
        
        messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.effectiveRate)
    }
    
    private func allEffectsToggled() {
        
        broadcastStateChangeNotification()
        messenger.publish(.Effects.playbackRateChanged, payload: timeStretchUnit.effectiveRate)
    }
    
    func trackChanged(_ notification: TrackTransitionNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        updateSettingsMemoryControls(forTrack: notification.endTrack)
        messenger.publish(.Effects.updateEffectsUnitView, payload: EffectsUnitType.master)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private func broadcastStateChangeNotification() {
        
        // Update the bypass buttons for the effects units
        messenger.publish(.Effects.unitStateChanged)
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        masterUnitView.redrawFuseBoxMenu()
    }
    
    override func colorSchemeChanged() {

        super.colorSchemeChanged()
        masterUnitView.redrawMenuAndToggle()
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        
        if masterUnit.state == .active {
            masterUnitView.redrawMenuAndToggle()
        }
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        if masterUnit.state == .bypassed {
            masterUnitView.redrawMenuAndToggle()
        }
    }
}
