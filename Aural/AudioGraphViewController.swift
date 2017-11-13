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
    @IBOutlet weak var pitchTabViewButton: MultiImageButton!
    @IBOutlet weak var timeTabViewButton: MultiImageButton!
    @IBOutlet weak var reverbTabViewButton: MultiImageButton!
    @IBOutlet weak var delayTabViewButton: MultiImageButton!
    @IBOutlet weak var filterTabViewButton: MultiImageButton!
    @IBOutlet weak var recorderTabViewButton: MultiImageButton!
    
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
        initRecorder()
        initTabGroup()
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .increaseBass, .decreaseBass, .increaseMids, .decreaseMids, .increaseTreble, .decreaseTreble, .increasePitch, .decreasePitch, .setPitch, .increaseRate, .decreaseRate, .setRate], subscriber: self)
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
        
        pitchTabViewButton.offStateImage = Images.imgPitchOff
        pitchTabViewButton.onStateImage = Images.imgPitchOn
        
        btnPitchBypass.image = appState.pitchBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        pitchTabViewButton.image = appState.pitchBypass ? pitchTabViewButton.offStateImage : pitchTabViewButton.onStateImage
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.pitchBypass
        
        pitchSlider.floatValue = appState.pitch
        lblPitchValue.stringValue = appState.formattedPitch
        
        pitchOverlapSlider.floatValue = appState.pitchOverlap
        lblPitchOverlapValue.stringValue = appState.formattedPitchOverlap
    }
    
    private func initTime(_ appState: UIAppState) {
        
        timeTabViewButton.offStateImage = Images.imgTimeOff
        timeTabViewButton.onStateImage = Images.imgTimeOn
        
        btnTimeBypass.image = appState.timeBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        timeTabViewButton.image = appState.timeBypass ? timeTabViewButton.offStateImage : timeTabViewButton.onStateImage
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.timeBypass
        
        timeSlider.floatValue = appState.timeStretchRate
        lblTimeStretchRateValue.stringValue = appState.formattedTimeStretchRate
        
        timeOverlapSlider.floatValue = appState.timeOverlap
        lblTimeOverlapValue.stringValue = appState.formattedTimeOverlap
    }
    
    private func initReverb(_ appState: UIAppState) {
        
        reverbTabViewButton.offStateImage = Images.imgReverbOff
        reverbTabViewButton.onStateImage = Images.imgReverbOn
        
        btnReverbBypass.image = appState.reverbBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        reverbTabViewButton.image = appState.reverbBypass ? reverbTabViewButton.offStateImage : reverbTabViewButton.onStateImage
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.reverbBypass
        
        reverbMenu.select(reverbMenu.item(withTitle: appState.reverbPreset))
        
        reverbSlider.floatValue = appState.reverbAmount
        lblReverbAmountValue.stringValue = appState.formattedReverbAmount
    }
    
    private func initDelay(_ appState: UIAppState) {
        
        delayTabViewButton.offStateImage = Images.imgDelayOff
        delayTabViewButton.onStateImage = Images.imgDelayOn
        
        btnDelayBypass.image = appState.delayBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        delayTabViewButton.image = appState.delayBypass ? delayTabViewButton.offStateImage : delayTabViewButton.onStateImage
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
        
        filterTabViewButton.offStateImage = Images.imgFilterOff
        filterTabViewButton.onStateImage = Images.imgFilterOn
        
        btnFilterBypass.image = appState.filterBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        filterTabViewButton.image = appState.filterBypass ? filterTabViewButton.offStateImage : filterTabViewButton.onStateImage
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
    
    private func initRecorder() {
    
        recorderTabViewButton.offStateImage = Images.imgRecorderOff
        recorderTabViewButton.onStateImage = Images.imgRecorderOn
        recorderTabViewButton.image = recorderTabViewButton.offStateImage
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
    
    private func showEQTab() {
        if (!fxTabView.isHidden) {
            eqTabViewAction(self)
        }
    }
    
    private func increaseBass() {
        updateEQSliders(graph.increaseBass())
        showEQTab()
    }
    
    private func decreaseBass() {
        updateEQSliders(graph.decreaseBass())
        showEQTab()
    }
    
    private func increaseMids() {
        updateEQSliders(graph.increaseMids())
        showEQTab()
    }
    
    private func decreaseMids() {
        updateEQSliders(graph.decreaseMids())
        showEQTab()
    }
    
    private func increaseTreble() {
        updateEQSliders(graph.increaseTreble())
        showEQTab()
    }
    
    private func decreaseTreble() {
        updateEQSliders(graph.decreaseTreble())
        showEQTab()
    }
    
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.togglePitchBypass()
        
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        pitchTabViewButton.image = newBypassState ? pitchTabViewButton.offStateImage : pitchTabViewButton.onStateImage
        pitchTabViewButton.needsDisplay = true
        
        btnPitchBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
    }
    
    @IBAction func pitchAction(_ sender: AnyObject) {
        lblPitchValue.stringValue = graph.setPitch(pitchSlider.floatValue)
    }
    
    private func setPitch(_ pitch: Float) {
        
        if graph.isPitchBypass() {
            _ = graph.togglePitchBypass()
        }
        
        lblPitchValue.stringValue = graph.setPitch(pitch)
        pitchSlider.floatValue = pitch
        
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        pitchTabViewButton.image = pitchTabViewButton.onStateImage
        pitchTabViewButton.needsDisplay = true
        btnPitchBypass.image = Images.imgSwitchOn
        
        // Show the Pitch tab if the Effects panel is shown
        if (!fxTabView.isHidden) {
            pitchTabViewAction(self)
        }
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
        pitchTabViewButton.image = pitchTabViewButton.onStateImage
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
        
        btnTimeBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
        timeTabViewButton.image = newBypassState ? timeTabViewButton.offStateImage : timeTabViewButton.onStateImage
        timeTabViewButton.needsDisplay = true
        
        let newRate = newBypassState ? 1 : timeSlider.floatValue
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
    }
    
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(timeSlider.floatValue)
        
        if (!graph.isTimeBypass()) {
            SyncMessenger.publishNotification(PlaybackRateChangedNotification(timeSlider.floatValue))
        }
    }
    
    private func setRate(_ rate: Float) {
        
        // Ensure unit is activated
        if graph.isTimeBypass() {
            _ = graph.toggleTimeBypass()
        }
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(rate)
        timeSlider.floatValue = rate
        
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        timeTabViewButton.image = timeTabViewButton.onStateImage
        timeTabViewButton.needsDisplay = true
        btnTimeBypass.image = Images.imgSwitchOn
        
        if (!fxTabView.isHidden) {
            timeTabViewAction(self)
        }
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rate))
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
        timeTabViewButton.image = timeTabViewButton.onStateImage
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
        reverbTabViewButton.image = newBypassState ? reverbTabViewButton.offStateImage : reverbTabViewButton.onStateImage
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
        delayTabViewButton.image = newBypassState ? delayTabViewButton.offStateImage : delayTabViewButton.onStateImage
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
        filterTabViewButton.image = newBypassState ? filterTabViewButton.offStateImage : filterTabViewButton.onStateImage
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
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .muteOrUnmute: muteOrUnmute()
            
        case .decreaseVolume: decreaseVolume()
            
        case .increaseVolume: increaseVolume()
            
        case .panLeft: panLeft()
            
        case .panRight: panRight()
            
        case .increaseBass: increaseBass()
            
        case .decreaseBass: decreaseBass()
            
        case .increaseMids: increaseMids()
            
        case .decreaseMids: decreaseMids()
            
        case .increaseTreble: increaseTreble()
            
        case .decreaseTreble: decreaseTreble()
            
        case .increasePitch: increasePitch()
            
        case .decreasePitch: decreasePitch()
            
        case .setPitch: setPitch(message.value!)
            
        case .increaseRate: increaseRate()
            
        case .decreaseRate: decreaseRate()
            
        case .setRate: setRate(message.value!)
            
        default: return
            
        }
    }
}
