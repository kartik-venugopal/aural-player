import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeViewController: FXUnitViewController {
    
    @IBOutlet weak var timeView: TimeView!
    
    @IBOutlet weak var lblRate: VALabel!
    @IBOutlet weak var lblRateMin: VALabel!
    @IBOutlet weak var lblRateMax: VALabel!
    @IBOutlet weak var lblRateValue: VALabel!
    
    @IBOutlet weak var lblOverlap: VALabel!
    @IBOutlet weak var lblOverlapMin: VALabel!
    @IBOutlet weak var lblOverlapMax: VALabel!
    @IBOutlet weak var lblOverlapValue: VALabel!
    
    @IBOutlet weak var lblPitchShiftValue: VALabel!
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    override var nibName: String? {return "Time"}
    
    var timeUnit: TimeUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.timeUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .time
        fxUnit = graph.timeUnit
        presetsWrapper = PresetsWrapper<TimePreset, TimePresets>(timeUnit.presets)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribe(self, .timeFXUnit_decreaseRate, self.decreaseRate)
        Messenger.subscribe(self, .timeFXUnit_increaseRate, self.increaseRate)
        Messenger.subscribe(self, .timeFXUnit_setRate, self.setRate(_:))
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        timeView.initialize(self.unitStateFunction)
    }

    override func initControls() {

        super.initControls()
        timeView.setState(timeUnit.rate, timeUnit.formattedRate, timeUnit.overlap, timeUnit.formattedOverlap, timeUnit.shiftPitch, timeUnit.formattedPitch)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        timeView.stateChanged()
    }

    // Activates/deactivates the Time stretch effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {

        super.bypassAction(sender)
        
        // The playback rate may have changed, send out a notification
        Messenger.publish(.fx_playbackRateChanged, payload: timeUnit.effectiveRate)
    }

    // Toggles the "pitch shift" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: AnyObject) {

        timeUnit.shiftPitch = timeView.shiftPitch
        updatePitchShift()
    }

    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {

        timeUnit.rate = timeView.rate
        timeView.setRate(timeUnit.rate, timeUnit.formattedRate, timeUnit.formattedPitch)

        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if timeUnit.isActive {
            Messenger.publish(.fx_playbackRateChanged, payload: timeUnit.rate)
        }
    }

    // Sets the playback rate to a specific value
    private func setRate(_ rate: Float) {

        timeUnit.rate = rate
        timeUnit.ensureActive()
        rateChange((rate, timeUnit.formattedRate))
    }

    // Increases the playback rate by a certain preset increment
    private func increaseRate() {
        rateChange(timeUnit.increaseRate())
    }

    // Decreases the playback rate by a certain preset decrement
    private func decreaseRate() {
        rateChange(timeUnit.decreaseRate())
    }

    // Changes the playback rate to a specific value
    private func rateChange(_ rateInfo: (rate: Float, rateString: String)) {

        Messenger.publish(.fx_unitStateChanged)

        timeView.setRate(rateInfo.rate, rateInfo.rateString, timeUnit.formattedPitch)
        stateChanged()

        showThisTab()

        Messenger.publish(.fx_playbackRateChanged, payload: rateInfo.rate)
    }

    // Updates the Overlap parameter of the Time stretch effects unit
    @IBAction func timeOverlapAction(_ sender: Any) {
        
        timeUnit.overlap = timeView.overlap
        timeView.setOverlap(timeUnit.overlap, timeUnit.formattedOverlap)
    }

    // Updates the label that displays the pitch shift value
    private func updatePitchShift() {
        timeView.updatePitchShift(timeUnit.formattedPitch)
    }
    
    override func changeTextSize(_ textSize: TextSize) {
        
        super.changeTextSize(textSize)
        btnShiftPitch.redraw()
    }
    
    override func applyFontSet(_ fontSet: FontSet) {
        
        super.applyFontSet(fontSet)
        btnShiftPitch.redraw()
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
        
        btnShiftPitch.attributedTitle = NSAttributedString(string: btnShiftPitch.title, attributes: [NSAttributedString.Key.foregroundColor: scheme.effects.functionCaptionTextColor])
        
        btnShiftPitch.attributedAlternateTitle = NSAttributedString(string: btnShiftPitch.title, attributes: [NSAttributedString.Key.foregroundColor: scheme.effects.functionCaptionTextColor])
    }
    
    override func changeSliderColors() {
        timeView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if timeUnit.isActive {
            timeView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if timeUnit.state == .bypassed {
            timeView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if timeUnit.state == .suppressed {
            timeView.redrawSliders()
        }
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
        
        super.changeFunctionCaptionTextColor(color)
        timeView.changeFunctionCaptionTextColor()
    }
}
