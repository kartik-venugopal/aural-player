//
//  PlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    @IBOutlet weak var btnVolume: TintedImageButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblVolume: VALabel!
    @IBOutlet weak var lblPan: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    var autoHidingVolumeLabel: AutoHidingView!
    var autoHidingPanLabel: AutoHidingView!
    
    @IBOutlet weak var lblPanCaption: VALabel!
    @IBOutlet weak var lblPanCaption2: VALabel!
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    let soundPreferences: SoundPreferences = ObjectGraph.preferences.soundPreferences
    
    let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    lazy var messenger = Messenger(for: self)
    
    // Numerical ranges
    let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    
    override func viewDidLoad() {
        
        // Ugly hack to properly align pan slider on Big Sur.
        if SystemUtils.isBigSur, showsPanControl {
            panSlider.moveUp(distance: 3)
        }
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, Self.feedbackLabelAutoHideIntervalSeconds)
        volumeSlider.floatValue = audioGraph.volume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        if showsPanControl {
            
            autoHidingPanLabel = AutoHidingView(lblPan, Self.feedbackLabelAutoHideIntervalSeconds)
            panSlider.floatValue = audioGraph.balance
            panChanged(audioGraph.balance, false)
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
        
        let newVolume = audioGraph.decreaseVolume(inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    func increaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.increaseVolume(inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    func volumeChanged(_ volume: Float, _ muted: Bool, _ updateSlider: Bool = true, _ showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = ValueFormatter.formatVolume(volume)
        
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
        
        audioGraph.balance = panSlider.floatValue
        panChanged(audioGraph.balance)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    func panLeft() {
        
        panChanged(audioGraph.panLeft())
        panSlider.floatValue = audioGraph.balance
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    func panRight() {
        
        panChanged(audioGraph.panRight())
        panSlider.floatValue = audioGraph.balance
    }
    
    func panChanged(_ pan: Float, _ showFeedback: Bool = true) {
        
        lblPan.stringValue = ValueFormatter.formatPan(pan)
        
        // Shows and automatically hides the pan label after a preset time interval
        if showFeedback {
            autoHidingPanLabel.showView()
        }
    }
    
    func trackChanged(_ newTrack: Track?) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if let theNewTrack = newTrack, soundProfiles.hasFor(theNewTrack) {

            volumeChanged(audioGraph.volume, audioGraph.muted)
            
            if showsPanControl {
                
                panChanged(audioGraph.balance)
                panSlider.floatValue = audioGraph.balance
            }
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
