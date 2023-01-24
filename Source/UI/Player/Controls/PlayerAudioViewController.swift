//
//  PlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for player volume and pan
 */
class PlayerAudioViewController: NSViewController, Destroyable {
    
    var showsPanControl: Bool {true}
    
    // Volume/pan controls
    @IBOutlet weak var btnAdvancedVolume: TintedImageButton!
    @IBOutlet weak var btnSimpleVolume: TintedImageButton!
    
    var btnVolume: TintedImageButton! {
        uiState.controlsViewType == .simple ? btnSimpleVolume : btnAdvancedVolume
    }
    
    @IBOutlet weak var advancedVolumeSlider: NSSlider!
    @IBOutlet weak var simpleVolumeSlider: NSSlider!
    
    var volumeSlider: NSSlider! {
        uiState.controlsViewType == .simple ? simpleVolumeSlider : advancedVolumeSlider
    }
    
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblAdvancedVolume: VALabel!
    @IBOutlet weak var lblSimpleVolume: VALabel!
    
    var lblVolume: VALabel! {
        uiState.controlsViewType == .simple ? lblSimpleVolume : lblAdvancedVolume
    }
    
    var simpleControls: [NSView] = []
    var advancedControls: [NSView] = []
    
    @IBOutlet weak var lblPan: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    var autoHidingVolumeLabel: AutoHidingView!
    var autoHidingPanLabel: AutoHidingView!
    
    @IBOutlet weak var lblPanCaption: VALabel!
    @IBOutlet weak var lblPanCaption2: VALabel!
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    var audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    let soundProfiles: SoundProfiles = objectGraph.audioGraphDelegate.soundProfiles
    let soundPreferences: SoundPreferences = objectGraph.preferences.soundPreferences
    
    let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    lazy var uiState: PlayerUIState = objectGraph.playerUIState
    
    lazy var messenger = Messenger(for: self)
    
    // Numerical ranges
    let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    
    override func viewDidLoad() {
        
        // Ugly hack to properly align pan slider on Big Sur.
        if System.isBigSur, showsPanControl {
            panSlider.moveUp(distance: 3)
        }
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, Self.feedbackLabelAutoHideIntervalSeconds)
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        if showsPanControl {
            
            autoHidingPanLabel = AutoHidingView(lblPan, Self.feedbackLabelAutoHideIntervalSeconds)
            panSlider.floatValue = audioGraph.pan
            panChanged(audioGraph.pan, false)
        }
        
        initSubscriptions()
    }
    
    func initSubscriptions() {}
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // Updates the volume
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.volume = volumeSlider.floatValue
        volumeChanged(audioGraph.volume, audioGraph.muted, false)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        muteOrUnmute()
    }
    
    func muteOrUnmute() {
        
        audioGraph.muted.toggle()
        updateVolumeMuteButtonImage(audioGraph.volume, audioGraph.muted)
    }
    
    // Decreases the volume by a certain preset decrement
    func decreaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.decreaseVolume(inputMode: inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    func increaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.increaseVolume(inputMode: inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    func volumeChanged(_ volume: Float, _ muted: Bool, _ updateSlider: Bool = true, _ showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = audioGraph.formattedVolume
        
        updateVolumeMuteButtonImage(volume, muted)
        
        // Shows and automatically hides the volume label after a preset time interval
        if showFeedback {
            autoHidingVolumeLabel.showView()
        }
    }
    
    func updateVolumeMuteButtonImage(_ volume: Float, _ muted: Bool) {

        if muted {
            
            btnVolume.baseImage = Images.imgMute
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
            case highVolumeRange:
                
                btnVolume.baseImage = Images.imgVolumeHigh
                
            case mediumVolumeRange:
                
                btnVolume.baseImage = Images.imgVolumeMedium
                
            case lowVolumeRange:
                
                btnVolume.baseImage = Images.imgVolumeLow
                
            default:
                
                btnVolume.baseImage = Images.imgVolumeZero
            }
        }
    }
    
    // Updates the stereo pan
    @IBAction func panAction(_ sender: AnyObject) {
        
        audioGraph.pan = panSlider.floatValue
        panChanged(audioGraph.pan)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    func panLeft() {
        
        panChanged(audioGraph.panLeft())
        panSlider.floatValue = audioGraph.pan
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    func panRight() {
        
        panChanged(audioGraph.panRight())
        panSlider.floatValue = audioGraph.pan
    }
    
    func panChanged(_ pan: Float, _ showFeedback: Bool = true) {
        
        lblPan.stringValue = audioGraph.formattedPan
        
        // Shows and automatically hides the pan label after a preset time interval
        if showFeedback {
            autoHidingPanLabel.showView()
        }
    }
    
    func changeControlsView(to newControlsView: PlayerControlsViewType) {
        
        if newControlsView == .simple {
            
            advancedControls.forEach {$0.hide()}
            simpleControls.forEach {$0.show()}
            
        } else {
            
            simpleControls.forEach {$0.hide()}
            advancedControls.forEach {$0.show()}
        }

        autoHidingVolumeLabel.view = lblVolume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        applyTheme()
    }
    
    func trackChanged(_ newTrack: Track?) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        
        volumeChanged(audioGraph.volume, audioGraph.muted)
        
        if uiState.controlsViewType == .advanced && showsPanControl {
            
            panChanged(audioGraph.pan)
            panSlider.floatValue = audioGraph.pan
        }
    }
    
    // MARK: Message handling
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        [lblVolume, lblPan, lblPanCaption, lblPanCaption2].forEach {$0?.font = fontSchemesManager.systemScheme.player.feedbackFont}
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)   // This call will also take care of toggle buttons.
        changeSliderColors()
        changeSliderValueTextColor(scheme.player.sliderValueTextColor)
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        btnVolume.reTint()
        
        if showsPanControl {
            
            lblPanCaption.textColor = color
            lblPanCaption2.textColor = color
        }
    }
    
    func changeSliderColors() {
        [volumeSlider, panSlider].forEach {$0?.redraw()}
    }
    
    func changeSliderValueTextColor(_ color: NSColor) {
        
        lblVolume.textColor = color
        lblPan?.textColor = color
    }
}
