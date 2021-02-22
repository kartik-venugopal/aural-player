import Cocoa

/*
    View controller for the EQ (Equalizer) effects unit
 */
class EQViewController: FXUnitViewController {
    
    @IBOutlet weak var eqView: EQView!
    
    private var eqUnit: EQUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.eqUnit
    
    override var nibName: String? {return "EQ"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.unitType = .eq
        self.fxUnit = graph.eqUnit
        self.presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        eqView.initialize(#selector(self.eqSliderAction(_:)), self, self.unitStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribe(self, .eqFXUnit_decreaseBass, self.decreaseBass)
        Messenger.subscribe(self, .eqFXUnit_increaseBass, self.increaseBass)
        
        Messenger.subscribe(self, .eqFXUnit_decreaseMids, self.decreaseMids)
        Messenger.subscribe(self, .eqFXUnit_increaseMids, self.increaseMids)
        
        Messenger.subscribe(self, .eqFXUnit_decreaseTreble, self.decreaseTreble)
        Messenger.subscribe(self, .eqFXUnit_increaseTreble, self.increaseTreble)

        Messenger.subscribe(self, .changeTabButtonTextColor, self.changeTabButtonTextColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonColor, self.changeSelectedTabButtonColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonTextColor, self.changeSelectedTabButtonTextColor(_:))
    }
    
    override func initControls() {
        
        super.initControls()
        eqView.setState(eqUnit.type, eqUnit.bands, eqUnit.globalGain)
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        eqUnit.type = eqView.type
        eqView.typeChanged(eqUnit.bands, eqUnit.globalGain)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        eqView.stateChanged()
    }
    
    @IBAction func eqGlobalGainAction(_ sender: EffectsUnitSlider) {
        eqUnit.globalGain = sender.floatValue
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: EffectsUnitSlider) {
        eqUnit.setBand(sender.tag, gain: sender.floatValue)
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
        bandsUpdated(eqUnit.increaseBass())
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
        bandsUpdated(eqUnit.decreaseBass())
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
        bandsUpdated(eqUnit.increaseMids())
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
        bandsUpdated(eqUnit.decreaseMids())
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
        bandsUpdated(eqUnit.increaseTreble())
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
        bandsUpdated(eqUnit.decreaseTreble())
    }
    
    private func bandsUpdated(_ bands: [Float]) {
        
        stateChanged()
        eqView.bandsUpdated(bands, eqUnit.globalGain)
        
        Messenger.publish(.fx_unitStateChanged)
        showThisTab()
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        super.applyFontScheme(fontScheme)
        eqView.applyFontScheme(fontScheme)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        
        changeSelectedTabButtonColor(scheme.general.selectedTabButtonColor)
        changeTabButtonTextColor(scheme.general.tabButtonTextColor)
        changeSelectedTabButtonTextColor(scheme.general.selectedTabButtonTextColor)
        changeSliderColors()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if eqUnit.state == .active {
            eqView.changeActiveUnitStateColor(color)
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if eqUnit.state == .bypassed {
            eqView.changeBypassedUnitStateColor(color)
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if eqUnit.state == .suppressed {
            eqView.changeSuppressedUnitStateColor(color)
        }
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        eqView.changeSelectedTabButtonColor()
    }
    
    func changeTabButtonTextColor(_ color: NSColor) {
        eqView.changeTabButtonTextColor()
    }
    
    func changeSelectedTabButtonTextColor(_ color: NSColor) {
        eqView.changeSelectedTabButtonTextColor()
    }
    
    override func changeSliderColors() {
        eqView.changeSliderColor()
    }
}
