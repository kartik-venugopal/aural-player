/*
    View controller for the all controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class AudioGraphViewController: NSViewController, ActionMessageSubscriber {
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var lblVolume: NSTextField!
    
    @IBOutlet weak var panSlider: NSSlider!
    @IBOutlet weak var lblPan: NSTextField!
    
    // Effects panel tab view and its buttons
    
    @IBOutlet weak var fxTabView: NSTabView!
    
    @IBOutlet weak var eqTabViewButton: NSButton!
    @IBOutlet weak var pitchTabViewButton: NSButton!
    @IBOutlet weak var timeTabViewButton: NSButton!
    @IBOutlet weak var reverbTabViewButton: NSButton!
    @IBOutlet weak var delayTabViewButton: NSButton!
    @IBOutlet weak var filterTabViewButton: NSButton!
    @IBOutlet weak var recorderTabViewButton: NSButton!
    
    private var fxTabViewButtons: [NSButton]?
    
    // Parametric equalizer controls
    @IBOutlet weak var eqGlobalGainSlider: NSSlider!
    @IBOutlet weak var eqSlider1k: NSSlider!
    @IBOutlet weak var eqSlider64: NSSlider!
    @IBOutlet weak var eqSlider16k: NSSlider!
    @IBOutlet weak var eqSlider8k: NSSlider!
    @IBOutlet weak var eqSlider4k: NSSlider!
    @IBOutlet weak var eqSlider2k: NSSlider!
    @IBOutlet weak var eqSlider32: NSSlider!
    @IBOutlet weak var eqSlider512: NSSlider!
    @IBOutlet weak var eqSlider256: NSSlider!
    @IBOutlet weak var eqSlider128: NSSlider!
    @IBOutlet weak var eqPresets: NSPopUpButton!
    
    private var eqSliders: [NSSlider] = []
    
    // Pitch controls
    @IBOutlet weak var btnPitchBypass: NSButton!
    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var pitchOverlapSlider: NSSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    // Time controls
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var timeOverlapSlider: NSSlider!
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Reverb controls
    @IBOutlet weak var btnReverbBypass: NSButton!
    @IBOutlet weak var reverbMenu: NSPopUpButton!
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // Delay controls
    @IBOutlet weak var btnDelayBypass: NSButton!
    @IBOutlet weak var delayTimeSlider: NSSlider!
    @IBOutlet weak var delayAmountSlider: NSSlider!
    @IBOutlet weak var btnTimeBypass: NSButton!
    @IBOutlet weak var delayCutoffSlider: NSSlider!
    @IBOutlet weak var delayFeedbackSlider: NSSlider!
    
    @IBOutlet weak var lblDelayTimeValue: NSTextField!
    @IBOutlet weak var lblDelayAmountValue: NSTextField!
    @IBOutlet weak var lblDelayFeedbackValue: NSTextField!
    @IBOutlet weak var lblDelayLowPassCutoffValue: NSTextField!
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: NSButton!
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    @IBOutlet weak var lblFilterBassRange: NSTextField!
    @IBOutlet weak var lblFilterMidRange: NSTextField!
    @IBOutlet weak var lblFilterTrebleRange: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    // Feedback label hiding timers
    private var volumeLabelHidingTimer: Timer?
    private var panLabelHidingTimer: Timer?
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()
        
        initVolumeAndPan(appState)
        initEQ(appState)
        initPitch(appState)
        initTime(appState)
        initReverb(appState)
        initDelay(appState)
        initFilter(appState)
        initTabGroup()
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .increaseBass, .decreaseBass, .increasePitch, .decreasePitch, .increaseRate, .decreaseRate], subscriber: self)
    }
    
    private func initVolumeAndPan(_ appState: UIAppState) {
        
        volumeSlider.floatValue = appState.volume
        setVolumeImage(appState.muted)
        panSlider.floatValue = appState.balance
    }
    
    private func initEQ(_ appState: UIAppState) {
        
        eqSliders = [eqSlider32, eqSlider64, eqSlider128, eqSlider256, eqSlider512, eqSlider1k, eqSlider2k, eqSlider4k, eqSlider8k, eqSlider16k]
        
        eqGlobalGainSlider.floatValue = appState.eqGlobalGain
        updateAllEQSliders(appState.eqBands)
        
        (eqTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        
        // Don't select any items from the EQ presets menu
        eqPresets.selectItem(at: -1)
    }
    
    private func initPitch(_ appState: UIAppState) {
        
        btnPitchBypass.image = appState.pitchBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.pitchBypass
        
        pitchSlider.floatValue = appState.pitch
        lblPitchValue.stringValue = appState.formattedPitch
        
        pitchOverlapSlider.floatValue = appState.pitchOverlap
        lblPitchOverlapValue.stringValue = appState.formattedPitchOverlap
    }
    
    private func initTime(_ appState: UIAppState) {
        
        btnTimeBypass.image = appState.timeBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.timeBypass
        
        timeSlider.floatValue = appState.timeStretchRate
        lblTimeStretchRateValue.stringValue = appState.formattedTimeStretchRate
        
        timeOverlapSlider.floatValue = appState.timeOverlap
        lblTimeOverlapValue.stringValue = appState.formattedTimeOverlap
    }
    
    private func initReverb(_ appState: UIAppState) {
        
        btnReverbBypass.image = appState.reverbBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.reverbBypass
        
        reverbMenu.select(reverbMenu.item(withTitle: appState.reverbPreset))
        
        reverbSlider.floatValue = appState.reverbAmount
        lblReverbAmountValue.stringValue = appState.formattedReverbAmount
    }
    
    private func initDelay(_ appState: UIAppState) {
        
        btnDelayBypass.image = appState.delayBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.delayBypass
        
        delayAmountSlider.floatValue = appState.delayAmount
        lblDelayAmountValue.stringValue = appState.formattedDelayAmount
        
        delayTimeSlider.doubleValue = appState.delayTime
        lblDelayTimeValue.stringValue = appState.formattedDelayTime
        
        delayFeedbackSlider.floatValue = appState.delayFeedback
        lblDelayFeedbackValue.stringValue = appState.formattedDelayFeedback
        
        delayCutoffSlider.floatValue = appState.delayLowPassCutoff
        lblDelayLowPassCutoffValue.stringValue = appState.formattedDelayLowPassCutoff
    }
    
    private func initFilter(_ appState: UIAppState) {
        
        btnFilterBypass.image = appState.filterBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        (filterTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.filterBypass
        
        filterBassSlider.initialize(AppConstants.bass_min, AppConstants.bass_max, appState.filterBassMin, appState.filterBassMax, {
            (slider: RangeSlider) -> Void in
            self.filterBassChanged()
        })
        
        filterMidSlider.initialize(AppConstants.mid_min, AppConstants.mid_max, appState.filterMidMin, appState.filterMidMax, {
            (slider: RangeSlider) -> Void in
            self.filterMidChanged()
        })
        
        filterTrebleSlider.initialize(AppConstants.treble_min, AppConstants.treble_max, appState.filterTrebleMin, appState.filterTrebleMax, {
            (slider: RangeSlider) -> Void in
            self.filterTrebleChanged()
        })
        
        lblFilterBassRange.stringValue = appState.formattedFilterBassRange
        lblFilterMidRange.stringValue = appState.formattedFilterMidRange
        lblFilterTrebleRange.stringValue = appState.formattedFilterTrebleRange
    }
    
    private func initTabGroup() {
        
        fxTabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        // Set tab view button highlight colors and refresh
        
        for btn in fxTabViewButtons! {
            
            (btn.cell as! EffectsUnitButtonCell).highlightColor = (btn === recorderTabViewButton ? Colors.tabViewRecorderButtonHighlightColor : Colors.tabViewEffectsButtonHighlightColor)
            
            btn.needsDisplay = true
        }
        
        // Select EQ tab view by default
        eqTabViewAction(self)
    }
    
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        graph.setVolume(volumeSlider.floatValue)
        setVolumeImage(graph.isMuted())
        showAndAutoHideVolumeLabel()
    }
    
    private func muteOrUnmute() {
        setVolumeImage(graph.toggleMute())
    }
    
    private func decreaseVolume() {
        volumeSlider.floatValue = graph.decreaseVolume()
        setVolumeImage(graph.isMuted())
        showAndAutoHideVolumeLabel()
    }
    
    private func increaseVolume() {
        volumeSlider.floatValue = graph.increaseVolume()
        setVolumeImage(graph.isMuted())
        showAndAutoHideVolumeLabel()
    }
    
    private func setVolumeImage(_ muted: Bool) {
        
        if (muted) {
            btnVolume.image = Images.imgMute
        } else {
            
            let volume = graph.getVolume()
            
            // Zero / Low / Medium / High (different images)
            if (volume > 200/3) {
                btnVolume.image = Images.imgVolumeHigh
            } else if (volume > 100/3) {
                btnVolume.image = Images.imgVolumeMedium
            } else if (volume > 0) {
                btnVolume.image = Images.imgVolumeLow
            } else {
                btnVolume.image = Images.imgVolumeZero
            }
        }
    }
    
    private func showAndAutoHideVolumeLabel() {
        
        // Format the text and show the feedback label
        lblVolume.stringValue = ValueFormatter.formatVolume(volumeSlider.floatValue)
        lblVolume.isHidden = false
        
        // Invalidate previously activated timer
        volumeLabelHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the label
        volumeLabelHidingTimer = Timer.scheduledTimer(timeInterval: UIConstants.feedbackLabelAutoHideIntervalSeconds, target: self, selector: #selector(self.hideVolumeLabel), userInfo: nil, repeats: false)
    }
    
    func hideVolumeLabel() {
        lblVolume.isHidden = true
    }
    
    @IBAction func panAction(_ sender: AnyObject) {
        graph.setBalance(panSlider.floatValue)
        showAndAutoHidePanLabel()
    }
    
    private func panLeft() {
        panSlider.floatValue = graph.panLeft()
        showAndAutoHidePanLabel()
    }
    
    private func panRight() {
        panSlider.floatValue = graph.panRight()
        showAndAutoHidePanLabel()
    }
    
    private func showAndAutoHidePanLabel() {
        
        // Format the text and show the feedback label
        lblPan.stringValue = ValueFormatter.formatPan(panSlider.floatValue)
        lblPan.isHidden = false
        
        // Invalidate previously activated timer
        panLabelHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the label
        panLabelHidingTimer = Timer.scheduledTimer(timeInterval: UIConstants.feedbackLabelAutoHideIntervalSeconds, target: self, selector: #selector(self.hidePanLabel), userInfo: nil, repeats: false)
    }
    
    func hidePanLabel() {
        lblPan.isHidden = true
    }
    
    @IBAction func eqGlobalGainAction(_ sender: AnyObject) {
        graph.setEQGlobalGain(eqGlobalGainSlider.floatValue)
    }
    
    @IBAction func eqSliderAction(_ sender: NSSlider) {
        // Slider tags match the corresponding EQ band indexes
        graph.setEQBand(sender.tag, gain: sender.floatValue)
    }
    
    @IBAction func eqPresetsAction(_ sender: AnyObject) {
        
        let preset = EQPresets.fromDescription((eqPresets.selectedItem?.title)!)
        
        let eqBands: [Int: Float] = preset.bands
        graph.setEQBands(eqBands)
        updateAllEQSliders(eqBands)
        
        // Don't select any of the items
        eqPresets.selectItem(at: -1)
    }
    
    private func updateAllEQSliders(_ eqBands: [Int: Float]) {
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        eqSliders.forEach({
            $0.floatValue = eqBands[$0.tag] ?? 0
        })
    }
    
    private func updateEQSliders(_ eqBands: [Int: Float]) {
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        for (index, gain) in eqBands {
            eqSliders[index].floatValue = gain
        }
    }
    
    private func increaseBass() {
        updateEQSliders(graph.increaseBass())
    }
    
    private func decreaseBass() {
        updateEQSliders(graph.decreaseBass())
    }
    
    private func increaseMids() {
        
    }
    
    private func decreaseMids() {
        
    }
    
    private func increaseTreble() {
        
    }
    
    private func decreaseTreble() {
        
    }
    
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.togglePitchBypass()
        
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        pitchTabViewButton.needsDisplay = true
        
        btnPitchBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
    }
    
    @IBAction func pitchAction(_ sender: AnyObject) {
        lblPitchValue.stringValue = graph.setPitch(pitchSlider.floatValue)
    }
    
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {
        lblPitchOverlapValue.stringValue = graph.setPitchOverlap(pitchOverlapSlider.floatValue)
    }
    
    private func increasePitch() {
        pitchChange(graph.increasePitch())
    }
    
    private func decreasePitch() {
        pitchChange(graph.decreasePitch())
    }
    
    private func pitchChange(_ pitchInfo: (pitch: Float, pitchString: String)) {
        
        pitchSlider.floatValue = pitchInfo.pitch
        lblPitchValue.stringValue = pitchInfo.pitchString
        
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        pitchTabViewButton.needsDisplay = true
        btnPitchBypass.image = Images.imgSwitchOn
        
        // Show the Pitch tab if the Effects panel is shown
        if (!fxTabView.isHidden) {
            pitchTabViewAction(self)
        }
    }
    
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeBypass()
        
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        timeTabViewButton.needsDisplay = true
        
        btnTimeBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
        
        let newRate = newBypassState ? 1 : timeSlider.floatValue
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
    }
    
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        let newRate = timeSlider.floatValue
        let rateValueStr = graph.setTimeStretchRate(newRate)
        lblTimeStretchRateValue.stringValue = rateValueStr
        
        let timeStretchActive = !graph.isTimeBypass()
        if (timeStretchActive) {
            SyncMessenger.publishNotification(PlaybackRateChangedNotification(newRate))
        }
    }
    
    private func increaseRate() {
        rateChange(graph.increaseRate())
    }
    
    private func decreaseRate() {
        rateChange(graph.decreaseRate())
    }
    
    private func rateChange(_ rateInfo: (rate: Float, rateString: String)) {
        
        timeSlider.floatValue = rateInfo.rate
        lblTimeStretchRateValue.stringValue = rateInfo.rateString
        
        let timeStretchActive = !graph.isTimeBypass()
        if (timeStretchActive) {
            SyncMessenger.publishNotification(PlaybackRateChangedNotification(rateInfo.rate))
        }
        
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        timeTabViewButton.needsDisplay = true
        btnTimeBypass.image = Images.imgSwitchOn
        
        if (!fxTabView.isHidden) {
            timeTabViewAction(self)
        }
    }
    
    @IBAction func timeOverlapAction(_ sender: Any) {
        lblTimeOverlapValue.stringValue = graph.setTimeOverlap(timeOverlapSlider.floatValue)
    }
    
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleReverbBypass()
        
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        reverbTabViewButton.needsDisplay = true
        
        btnReverbBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
    }
    
    @IBAction func reverbAction(_ sender: AnyObject) {
        graph.setReverb(ReverbPresets.fromDescription((reverbMenu.selectedItem?.title)!))
    }
    
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        lblReverbAmountValue.stringValue = graph.setReverbAmount(reverbSlider.floatValue)
    }
    
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleDelayBypass()
        
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        delayTabViewButton.needsDisplay = true
        
        btnDelayBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
    }
    
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        lblDelayAmountValue.stringValue = graph.setDelayAmount(delayAmountSlider.floatValue)
    }
    
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        lblDelayTimeValue.stringValue = graph.setDelayTime(delayTimeSlider.doubleValue)
    }
    
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        lblDelayFeedbackValue.stringValue = graph.setDelayFeedback(delayFeedbackSlider.floatValue)
    }
    
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        lblDelayLowPassCutoffValue.stringValue = graph.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
    }
    
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleFilterBypass()
        
        (filterTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        filterTabViewButton.needsDisplay = true
        
        btnFilterBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
    }
    
    private func filterBassChanged() {
        lblFilterBassRange.stringValue = graph.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
    }
    
    private func filterMidChanged() {
        lblFilterMidRange.stringValue = graph.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
    }
    
    private func filterTrebleChanged() {
        lblFilterTrebleRange.stringValue = graph.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
    }
    
    @IBAction func eqTabViewAction(_ sender: Any) {
        tabViewAction(eqTabViewButton, 0)
    }
    
    @IBAction func pitchTabViewAction(_ sender: Any) {
        tabViewAction(pitchTabViewButton, 1)
    }
    
    @IBAction func timeTabViewAction(_ sender: Any) {
        tabViewAction(timeTabViewButton, 2)
    }
    
    @IBAction func reverbTabViewAction(_ sender: Any) {
        tabViewAction(reverbTabViewButton, 3)
    }
    
    @IBAction func delayTabViewAction(_ sender: Any) {
        tabViewAction(delayTabViewButton, 4)
    }
    
    @IBAction func filterTabViewAction(_ sender: Any) {
        tabViewAction(filterTabViewButton, 5)
    }
    
    @IBAction func recorderTabViewAction(_ sender: Any) {
        tabViewAction(recorderTabViewButton, 6)
    }
    
    // Helper function to switch the tab group to a particular view
    private func tabViewAction(_ selectedButton: NSButton, _ tabIndex: Int) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        selectedButton.state = 1
        fxTabView.selectTabViewItem(at: tabIndex)
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .muteOrUnmute: muteOrUnmute()
            
        case .decreaseVolume: decreaseVolume()
            
        case .increaseVolume: increaseVolume()
            
        case .panLeft: panLeft()
            
        case .panRight: panRight()
            
        case .increaseBass: increaseBass()
            
        case .decreaseBass: decreaseBass()
            
        case .increasePitch: increasePitch()
            
        case .decreasePitch: decreasePitch()
            
        case .increaseRate: increaseRate()
            
        case .decreaseRate: decreaseRate()
            
        default: return
            
        }
    }
}
