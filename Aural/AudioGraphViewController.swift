/*
    View controller for the Effects unit (which controls the audio graph)
 */

import Cocoa

class AudioGraphViewController: NSViewController {
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    @IBOutlet weak var fxTabView: NSTabView!
    
    // Effects panel tab view buttons
    @IBOutlet weak var eqTabViewButton: NSButton!
    @IBOutlet weak var pitchTabViewButton: NSButton!
    @IBOutlet weak var timeTabViewButton: NSButton!
    @IBOutlet weak var reverbTabViewButton: NSButton!
    @IBOutlet weak var delayTabViewButton: NSButton!
    @IBOutlet weak var filterTabViewButton: NSButton!
    @IBOutlet weak var recorderTabViewButton: NSButton!
    
    private var fxTabViewButtons: [NSButton]?
    
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
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()
        
        // Volume and Pan
        
        volumeSlider.floatValue = appState.volume
        setVolumeImage(appState.muted)
        panSlider.floatValue = appState.balance
        
        // Effects unit
        
        fxTabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        // EQ
        
        eqGlobalGainSlider.floatValue = appState.eqGlobalGain
        updateEQSliders(appState.eqBands)
        
        (eqTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        
        // Don't select any items from the EQ presets menu
        eqPresets.selectItem(at: -1)
        
        // Pitch
        
        btnPitchBypass.image = appState.pitchBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.pitchBypass
        
        pitchSlider.floatValue = appState.pitch
        lblPitchValue.stringValue = appState.formattedPitch
        
        pitchOverlapSlider.floatValue = appState.pitchOverlap
        lblPitchOverlapValue.stringValue = appState.formattedPitchOverlap
        
        // Time
        
        btnTimeBypass.image = appState.timeBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.timeBypass
        
        timeSlider.floatValue = appState.timeStretchRate
        lblTimeStretchRateValue.stringValue = appState.formattedTimeStretchRate
        
        timeOverlapSlider.floatValue = appState.timeOverlap
        lblTimeOverlapValue.stringValue = appState.formattedTimeOverlap
        
        // Reverb
        
        btnReverbBypass.image = appState.reverbBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.reverbBypass
        
        reverbMenu.select(reverbMenu.item(withTitle: appState.reverbPreset))
        
        reverbSlider.floatValue = appState.reverbAmount
        lblReverbAmountValue.stringValue = appState.formattedReverbAmount
        
        // Delay
        
        btnDelayBypass.image = appState.delayBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !appState.delayBypass
        
        delayAmountSlider.floatValue = appState.delayAmount
        lblDelayAmountValue.stringValue = appState.formattedDelayAmount
        
        delayTimeSlider.doubleValue = appState.delayTime
        lblDelayTimeValue.stringValue = appState.formattedDelayTime
        
        delayFeedbackSlider.floatValue = appState.delayFeedback
        lblDelayFeedbackValue.stringValue = appState.formattedDelayFeedback
        
        delayCutoffSlider.floatValue = appState.delayLowPassCutoff
        lblDelayLowPassCutoffValue.stringValue = appState.formattedDelayLowPassCutoff
        
        // Filter
        
        btnFilterBypass.image = appState.filterBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
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
    }
    
    @IBAction func muteUnmuteAction(_ sender: AnyObject) {
        setVolumeImage(graph.toggleMute())
    }
    
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        volumeSlider.floatValue = graph.decreaseVolume()
        setVolumeImage(graph.isMuted())
    }
    
    @IBAction func increaseVolumeAction(_ sender: Any) {
        volumeSlider.floatValue = graph.increaseVolume()
        setVolumeImage(graph.isMuted())
    }
    
    private func setVolumeImage(_ muted: Bool) {
        
        if (muted) {
            btnVolume.image = UIConstants.imgMute
        } else {
            let vol = graph.getVolume()
            
            // Zero / Low / Medium / High (different images)
            if (vol > 200/3) {
                btnVolume.image = UIConstants.imgVolumeHigh
            } else if (vol > 100/3) {
                btnVolume.image = UIConstants.imgVolumeMedium
            } else if (vol > 0) {
                btnVolume.image = UIConstants.imgVolumeLow
            } else {
                btnVolume.image = UIConstants.imgVolumeZero
            }
        }
    }
    
    @IBAction func panAction(_ sender: AnyObject) {
        graph.setBalance(panSlider.floatValue)
    }
    
    @IBAction func panLeftAction(_ sender: Any) {
        panSlider.floatValue = graph.panLeft()
    }
    
    @IBAction func panRightAction(_ sender: Any) {
        panSlider.floatValue = graph.panRight()
    }
    
    private func updateEQSliders(_ eqBands: [Int: Float]) {
        
        eqSlider32.floatValue = eqBands[32]!
        eqSlider64.floatValue = eqBands[64]!
        eqSlider128.floatValue = eqBands[128]!
        eqSlider256.floatValue = eqBands[256]!
        eqSlider512.floatValue = eqBands[512]!
        eqSlider1k.floatValue = eqBands[1024]!
        eqSlider2k.floatValue = eqBands[2048]!
        eqSlider4k.floatValue = eqBands[4096]!
        eqSlider8k.floatValue = eqBands[8192]!
        eqSlider16k.floatValue = eqBands[16384]!
    }
    
    @IBAction func eqPresetsAction(_ sender: AnyObject) {
        
        let preset = EQPresets.fromDescription((eqPresets.selectedItem?.title)!)
        
        let eqBands: [Int: Float] = preset.bands
        graph.setEQBands(eqBands)
        updateEQSliders(eqBands)
        
        eqPresets.selectItem(at: -1)
    }
    
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.togglePitchBypass()
        
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        pitchTabViewButton.needsDisplay = true
        
        btnPitchBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        let pitchValueStr = graph.setPitch(pitchSlider.floatValue)
        lblPitchValue.stringValue = pitchValueStr
    }
    
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {
        let pitchOverlapValueStr = graph.setPitchOverlap(pitchOverlapSlider.floatValue)
        lblPitchOverlapValue.stringValue = pitchOverlapValueStr
    }
    
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeBypass()
        
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        timeTabViewButton.needsDisplay = true
        
        btnTimeBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        
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
            let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
            SyncMessenger.publishNotification(playbackRateChangedMsg)
        }
    }
    
    @IBAction func timeOverlapAction(_ sender: Any) {
        
        let timeOverlapValueStr = graph.setTimeOverlap(timeOverlapSlider.floatValue)
        lblTimeOverlapValue.stringValue = timeOverlapValueStr
    }
    
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleReverbBypass()
        
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        reverbTabViewButton.needsDisplay = true
        
        btnReverbBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func reverbAction(_ sender: AnyObject) {
        
        let preset: ReverbPresets = ReverbPresets.fromDescription((reverbMenu.selectedItem?.title)!)
        graph.setReverb(preset)
    }
    
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        let reverbAmountValueStr = graph.setReverbAmount(reverbSlider.floatValue)
        lblReverbAmountValue.stringValue = reverbAmountValueStr
    }
    
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleDelayBypass()
        
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        delayTabViewButton.needsDisplay = true
        
        btnDelayBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        let delayAmountValueStr = graph.setDelayAmount(delayAmountSlider.floatValue)
        lblDelayAmountValue.stringValue = delayAmountValueStr
    }
    
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        let delayTimeValueStr = graph.setDelayTime(delayTimeSlider.doubleValue)
        lblDelayTimeValue.stringValue = delayTimeValueStr
    }
    
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        let delayFeedbackValueStr = graph.setDelayFeedback(delayFeedbackSlider.floatValue)
        lblDelayFeedbackValue.stringValue = delayFeedbackValueStr
    }
    
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        let delayCutoffValueStr = graph.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
        lblDelayLowPassCutoffValue.stringValue = delayCutoffValueStr
    }
    
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleFilterBypass()
        
        (filterTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        filterTabViewButton.needsDisplay = true
        
        btnFilterBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func eqGlobalGainAction(_ sender: AnyObject) {
        graph.setEQGlobalGain(eqGlobalGainSlider.floatValue)
    }
    
    @IBAction func eqSlider32Action(_ sender: AnyObject) {
        graph.setEQBand(32, gain: eqSlider32.floatValue)
    }
    
    @IBAction func eqSlider64Action(_ sender: AnyObject) {
        graph.setEQBand(64, gain: eqSlider64.floatValue)
    }
    
    @IBAction func eqSlider128Action(_ sender: AnyObject) {
        graph.setEQBand(128, gain: eqSlider128.floatValue)
    }
    
    @IBAction func eqSlider256Action(_ sender: AnyObject) {
        graph.setEQBand(256, gain: eqSlider256.floatValue)
    }
    
    @IBAction func eqSlider512Action(_ sender: AnyObject) {
        graph.setEQBand(512, gain: eqSlider512.floatValue)
    }
    
    @IBAction func eqSlider1kAction(_ sender: AnyObject) {
        graph.setEQBand(1024, gain: eqSlider1k.floatValue)
    }
    
    @IBAction func eqSlider2kAction(_ sender: AnyObject) {
        graph.setEQBand(2048, gain: eqSlider2k.floatValue)
    }
    
    @IBAction func eqSlider4kAction(_ sender: AnyObject) {
        graph.setEQBand(4096, gain: eqSlider4k.floatValue)
    }
    
    @IBAction func eqSlider8kAction(_ sender: AnyObject) {
        graph.setEQBand(8192, gain: eqSlider8k.floatValue)
    }
    
    @IBAction func eqSlider16kAction(_ sender: AnyObject) {
        graph.setEQBand(16384, gain: eqSlider16k.floatValue)
    }
    
    private func filterBassChanged() {
        let filterBassRangeStr = graph.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
        lblFilterBassRange.stringValue = filterBassRangeStr
    }
    
    private func filterMidChanged() {
        let filterMidRangeStr = graph.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
        lblFilterMidRange.stringValue = filterMidRangeStr
    }
    
    private func filterTrebleChanged() {
        let filterTrebleRangeStr = graph.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
        lblFilterTrebleRange.stringValue = filterTrebleRangeStr
    }
    
    @IBAction func eqTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        eqTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 0)
    }
    
    @IBAction func pitchTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        pitchTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 1)
    }
    
    @IBAction func timeTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        timeTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 2)
    }
    
    @IBAction func reverbTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        reverbTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 3)
    }
    
    @IBAction func delayTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        delayTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 4)
    }
    
    @IBAction func filterTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        filterTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 5)
    }
    
    @IBAction func recorderTabViewAction(_ sender: Any) {
        
        fxTabViewButtons!.forEach({$0.state = 0})
        
        recorderTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 6)
    }
}
