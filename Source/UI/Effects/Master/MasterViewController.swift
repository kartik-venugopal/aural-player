import Cocoa

class MasterViewController: FXUnitViewController {
    
    @IBOutlet weak var masterView: MasterView!
    
    @IBOutlet weak var lblAudioUnitsCaption: NSTextField!
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    private let soundPreferences: SoundPreferences = ObjectGraph.preferencesDelegate.preferences.soundPreferences
    private let playbackPreferences: PlaybackPreferences = ObjectGraph.preferencesDelegate.preferences.playbackPreferences
    
    private var masterUnit: MasterUnitDelegateProtocol {return graph.masterUnit}
    private var eqUnit: EQUnitDelegateProtocol {return graph.eqUnit}
    private var pitchUnit: PitchUnitDelegateProtocol {return graph.pitchUnit}
    private var timeUnit: TimeUnitDelegateProtocol {return graph.timeUnit}
    private var reverbUnit: ReverbUnitDelegateProtocol {return graph.reverbUnit}
    private var delayUnit: DelayUnitDelegateProtocol {return graph.delayUnit}
    private var filterUnit: FilterUnitDelegateProtocol {return graph.filterUnit}
    
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    override var nibName: String? {return "Master"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .master
        fxUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        
        masterView.initialize(graph.eqUnit.stateFunction, graph.pitchUnit.stateFunction, graph.timeUnit.stateFunction, graph.reverbUnit.stateFunction, graph.delayUnit.stateFunction, graph.filterUnit.stateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackChanged(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
        
        Messenger.subscribe(self, .masterFXUnit_toggleEffects, self.toggleEffects)
    }
    
    override func initControls() {
        
        super.initControls()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    private func toggleEffects() {
        bypassAction(self)
    }
    
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        super.presetsAction(sender)
        Messenger.publish(.fx_updateFXUnitView, payload: EffectsUnit.master)
    }
    
    private func updateButtons() {
        btnBypass.updateState()
        masterView.stateChanged()
    }
    
    private func broadcastStateChangeNotification() {
        // Update the bypass buttons for the effects units
        Messenger.publish(.fx_unitStateChanged)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        _ = timeUnit.toggleState()
        
        Messenger.publish(.fx_playbackRateChanged, payload: timeUnit.effectiveRate)
        
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    func trackChanged(_ notification: TrackTransitionNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if let newTrack = notification.endTrack, soundProfiles.hasFor(newTrack) {
            
            updateButtons()
            Messenger.publish(.fx_updateFXUnitView, payload: EffectsUnit.master)
        }
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblCaption.font = FontSchemes.systemScheme.effects.unitCaptionFont
        lblAudioUnitsCaption.font = FontSchemes.systemScheme.effects.masterUnitFunctionFont
        
        functionLabels.filter {$0 is EffectsUnitTriStateLabel}.forEach {
            $0.font = FontSchemes.systemScheme.effects.unitFunctionFont
        }
        
        presetsMenu.font = Fonts.menuFont
    }
    
    override func changeMainCaptionTextColor(_ color: NSColor) {
        
        super.changeMainCaptionTextColor(color)
        lblAudioUnitsCaption.textColor = color
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        masterView.changeActiveUnitStateColor(color)
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        masterView.changeBypassedUnitStateColor(color)
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        // Master unit can never be suppressed, but update other unit state buttons
        masterView.changeSuppressedUnitStateColor(color)
    }
    
    // MARK: Message handling
    
    override func stateChanged() {
        updateButtons()
    }
}
