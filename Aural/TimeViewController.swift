import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeViewController: FXUnitViewController {
    
    @IBOutlet weak var timeView: TimeView!
    
    override var nibName: String? {return "Time"}
    
    var timeUnit: TimeUnitDelegate {return graph.timeUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .time
        fxUnit = graph.timeUnit
        unitStateFunction = timeStateFunction
        presetsWrapper = PresetsWrapper<TimePreset, TimePresets>(timeUnit.presets)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        SyncMessenger.subscribe(actionTypes: [.increaseRate, .decreaseRate, .setRate], subscriber: self)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        timeView.initialize(unitStateFunction)
    }

    override func initControls() {

        super.initControls()
        
        timeView.stateChanged()
        timeView.setState(timeUnit.rate, timeUnit.formattedRate, timeUnit.overlap, timeUnit.formattedOverlap, timeUnit.shiftPitch, timeUnit.formattedPitch)
    }

    // Activates/deactivates the Time stretch effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {

        super.bypassAction(sender)
        
        timeView.stateChanged()
        let newBypassState = timeUnit.state != .active
        let newRate = newBypassState ? 1 : timeUnit.rate
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
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
        if (timeUnit.state == .active) {
            SyncMessenger.publishNotification(PlaybackRateChangedNotification(timeUnit.rate))
        }
    }

    // Sets the playback rate to a specific value
    private func setRate(_ rate: Float) {

        timeUnit.rate = rate
        timeUnit.ensureActive()
        
        timeView.stateChanged()
        timeView.setRate(rate, timeUnit.formattedRate, timeUnit.formattedPitch)

        showThisTab()

        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rate))
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

        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)

        timeView.setRate(rateInfo.rate, rateInfo.rateString, timeUnit.formattedPitch)

        btnBypass.on()
        timeView.stateChanged()

        showThisTab()

        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rateInfo.rate))
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

    // MARK: Message handling

    override func consumeNotification(_ notification: NotificationMessage) {
        
        super.consumeNotification(notification)

        if notification is EffectsUnitStateChangedNotification {
            timeView.stateChanged()
        }
    }

    override func consumeMessage(_ message: ActionMessage) {
        
        super.consumeMessage(message)

        if let message = message as? AudioGraphActionMessage {

            switch message.actionType {

            case .increaseRate: increaseRate()

            case .decreaseRate: decreaseRate()

            case .setRate: setRate(message.value!)

            default: return

            }
        }
    }
}
