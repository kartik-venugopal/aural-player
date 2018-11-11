import Cocoa

class MasterViewController: FXUnitViewController {
    
    @IBOutlet weak var masterView: MasterView!

    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    private let soundPreferences: SoundPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().soundPreferences
    private let playbackPreferences: PlaybackPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().playbackPreferences
    
    private var masterUnit: MasterUnitDelegate {return graph.masterUnit}
    private var eqUnit: EQUnitDelegate {return graph.eqUnit}
    private var pitchUnit: PitchUnitDelegate {return graph.pitchUnit}
    private var timeUnit: TimeUnitDelegate {return graph.timeUnit}
    private var reverbUnit: ReverbUnitDelegate {return graph.reverbUnit}
    private var delayUnit: DelayUnitDelegate {return graph.delayUnit}
    private var filterUnit: FilterUnitDelegate {return graph.filterUnit}
    
    override var nibName: String? {return "Master"}
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        masterView.initialize(eqStateFunction, pitchStateFunction, timeStateFunction, reverbStateFunction, delayStateFunction, filterStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.enableEffects, .disableEffects, .saveSoundProfile, .deleteSoundProfile], subscriber: self)
    }
    
    override func initControls() {
        
        super.initControls()
        updateButtons()
    }
    
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        updateButtons()
    }
    
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        super.presetsAction(sender)
        _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
    }
    
    private func updateButtons() {
        
        // Update the bypass buttons for the effects units
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        masterView.stateChanged()
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        updateButtons()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchUnit.toggleState()
        updateButtons()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let timeUnitActive = timeUnit.toggleState() == .active
        let newRate = timeUnitActive ? timeUnit.rate : 1
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(newRate))
        updateButtons()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        updateButtons()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        updateButtons()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        updateButtons()
    }
    
    private func saveSoundProfile() {
        
        if let plTrack = player.getPlayingTrack()?.track {
            SoundProfiles.saveProfile(plTrack, graph.volume, graph.balance, graph.getSettingsAsMasterPreset())
        }
    }
    
    private func deleteSoundProfile() {
        
        if let plTrack = player.getPlayingTrack()?.track {
            SoundProfiles.deleteProfile(plTrack)
        }
    }
    
    private func trackChanged(_ message: TrackChangedNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if soundPreferences.rememberEffectsSettings, let newTrack = message.newTrack?.track, let profile = SoundProfiles.profileForTrack(newTrack) {
            
            masterUnit.applyPreset(profile.effects)
            
            updateButtons()
            _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
        }
    }
    
    // MARK: Message handling
    
    override func consumeNotification(_ notification: NotificationMessage) {
        
        super.consumeNotification(notification)
        
        switch notification.messageType {
        
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        default: return
            
        }
    }
    
    override func consumeMessage(_ message: ActionMessage) {
        
        super.consumeMessage(message)
        
        switch message.actionType {
            
        case .enableEffects, .disableEffects:
            bypassAction(self)
            
        case .saveSoundProfile:
            saveSoundProfile()
            
        case .deleteSoundProfile:
            deleteSoundProfile()
            
        default: return
            
        }
    }
}
