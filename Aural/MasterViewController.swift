import Cocoa

class MasterViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, StringInputClient, NSMenuDelegate {
    
    @IBOutlet weak var btnMasterBypass: EffectsUnitBypassButton!
    
    @IBOutlet weak var masterView: MasterView!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private let soundPreferences: SoundPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().soundPreferences
    private let playbackPreferences: PlaybackPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().playbackPreferences
    
    private let masterPresets: MasterPresets = ObjectGraph.getAudioGraphDelegate().masterPresets
 
    override var nibName: String? {return "Master"}
    
    override func viewDidLoad() {
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification, .trackChangedNotification, .appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.enableEffects, .disableEffects, .saveSoundProfile, .deleteSoundProfile, .updateEffectsView], subscriber: self)
        
        oneTimeSetup()
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        presetsMenu.removeAllItems()
        
        // Initialize the menu with user-defined presets
        masterPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        masterView.initialize(eqStateFunction, pitchStateFunction, timeStateFunction, reverbStateFunction, delayStateFunction, filterStateFunction)
        
        self.menuNeedsUpdate(presetsMenu.menu!)
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
        
        // If specific startup behavior is defined, update controls accordingly
        // TODO: Move this to AudioGraphDelegate
        if soundPreferences.effectsSettingsOnStartupOption == .applyMasterPreset {
            
            if let preset = soundPreferences.masterPresetOnStartup_name {
                
                graph.applyMasterPreset(preset)
                
                _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
                
                // Don't select any of the items
                presetsMenu.selectItem(at: -1)
                
            } else {
                initControls()
            }
            
        } else {
            initControls()
        }
    }
    
    private func initControls() {
        updateButtons()
    }
    
    @IBAction func masterBypassAction(_ sender: AnyObject) {
        
        // Toggle the master bypass state (simple on/off)
        _ = graph.toggleMasterBypass()
        updateButtons()
    }
    
    @IBAction func masterPresetsAction(_ sender: AnyObject) {
        
        graph.applyMasterPreset(presetsMenu.titleOfSelectedItem!)

        _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
        
        // Don't select any of the items
        presetsMenu.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
//        _ = graph.toggleEQState()
        updateButtons()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
//        _ = graph.togglePitchState()
        updateButtons()
    }
    
    private func updateButtons() {
        
        btnMasterBypass.onIf(!graph.isMasterBypass())
        
        // Update the bypass buttons for the effects units
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        masterView.stateChanged()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
//        let newBypassState = graph.toggleTimeState() != .active
//
//        let newRate = newBypassState ? 1 : graph.getTimeRate().rate
//        SyncMessenger.publishNotification(PlaybackRateChangedNotification(newRate))
//
//        updateButtons()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
//        _ = graph.toggleReverbState()
        updateButtons()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
//        _ = graph.toggleDelayState()
        updateButtons()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
//        _ = graph.toggleFilterState()
        updateButtons()
    }
    
    private func effectsUnitStateChanged() {
        
        btnMasterBypass.onIf(!graph.isMasterBypass())
        masterView.stateChanged()
    }
    
    private func saveSoundProfile() {
        
        if let plTrack = player.getPlayingTrack()?.track {
            SoundProfiles.saveProfile(plTrack, graph.getVolume(), graph.getBalance(), graph.getSettingsAsMasterPreset())
        }
    }
    
    private func deleteSoundProfile() {
        
        if let plTrack = player.getPlayingTrack()?.track {
            SoundProfiles.deleteProfile(plTrack)
        }
    }
    
    private func trackChanged(_ message: TrackChangedNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if soundPreferences.rememberEffectsSettings {
            
            if let newTrack = message.newTrack {
                
                if let profile = SoundProfiles.profileForTrack(newTrack.track) {
                    
                    graph.applyMasterPreset(profile.effects)
                    
                    updateButtons()
                    _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
                    
                }
            }
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if soundPreferences.rememberEffectsSettings {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let plTrack = player.getPlayingTrack()?.track {
                
                // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the app is exiting
                if soundPreferences.rememberEffectsSettingsOption == .allTracks || SoundProfiles.profileForTrack(plTrack) != nil {
                    SoundProfiles.saveProfile(plTrack, graph.getVolume(), graph.getBalance(), graph.getSettingsAsMasterPreset())
                }
            }
        }
        
        // No ongoing recording, proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .effectsUnitStateChangedNotification:
            
            effectsUnitStateChanged()
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .enableEffects, .disableEffects:
            masterBypassAction(self)
            
        case .saveSoundProfile:
            saveSoundProfile()
            
        case .deleteSoundProfile:
            deleteSoundProfile()
            
        case .updateEffectsView:
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master {
                initControls()
            }
            
        default: return
            
        }
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Master preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !masterPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new Master preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        graph.saveMasterPreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}

typealias EffectsUnitStateFunction = () -> EffectsUnitState

typealias PresetsDataFunction = () -> [EffectsUnitPreset]
