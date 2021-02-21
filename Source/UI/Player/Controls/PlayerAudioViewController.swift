/*
    View controller for player volume and pan
 */
import Cocoa

class PlayerAudioViewController: NSViewController, NotificationSubscriber {
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: TintedImageButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblVolume: VALabel!
    @IBOutlet weak var lblPan: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    private var autoHidingVolumeLabel: AutoHidingView!
    private var autoHidingPanLabel: AutoHidingView!
    
    @IBOutlet weak var lblPanCaption: VALabel!
    @IBOutlet weak var lblPanCaption2: VALabel!
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    private let soundPreferences: SoundPreferences = ObjectGraph.preferences.soundPreferences
    
    // Numerical ranges
    private let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    private let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    private let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    override func viewDidLoad() {
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        autoHidingPanLabel = AutoHidingView(lblPan, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        
        volumeSlider.floatValue = audioGraph.volume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        panSlider.floatValue = audioGraph.balance
        panChanged(audioGraph.balance, false)
        
        applyFontSet(FontSets.systemFontSet)
        applyColorScheme(ColorSchemes.systemScheme)

        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to notifications
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
        
        Messenger.subscribe(self, .player_muteOrUnmute, self.muteOrUnmute)
        Messenger.subscribe(self, .player_decreaseVolume, self.decreaseVolume(_:))
        Messenger.subscribe(self, .player_increaseVolume, self.increaseVolume(_:))
        
        Messenger.subscribe(self, .player_panLeft, self.panLeft)
        Messenger.subscribe(self, .player_panRight, self.panRight)
        
        Messenger.subscribe(self, .applyFontSet, self.applyFontSet(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .player_changeSliderColors, self.changeSliderColors)
        Messenger.subscribe(self, .player_changeSliderValueTextColor, self.changeSliderValueTextColor(_:))
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
    
    private func muteOrUnmute() {
        
        audioGraph.muted.toggle()
        updateVolumeMuteButtonImage(audioGraph.volume, audioGraph.muted)
    }
    
    // Decreases the volume by a certain preset decrement
    private func decreaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.decreaseVolume(inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    private func increaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.increaseVolume(inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    private func volumeChanged(_ volume: Float, _ muted: Bool, _ updateSlider: Bool = true, _ showFeedback: Bool = true) {
        
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
    
    private func updateVolumeMuteButtonImage(_ volume: Float, _ muted: Bool) {

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
    private func panLeft() {
        
        panChanged(audioGraph.panLeft())
        panSlider.floatValue = audioGraph.balance
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    private func panRight() {
        
        panChanged(audioGraph.panRight())
        panSlider.floatValue = audioGraph.balance
    }
    
    private func panChanged(_ pan: Float, _ showFeedback: Bool = true) {
        
        lblPan.stringValue = ValueFormatter.formatPan(pan)
        
        // Shows and automatically hides the pan label after a preset time interval
        if showFeedback {
            autoHidingPanLabel.showView()
        }
    }
    
    private func applyFontSet(_ fontSet: FontSet) {
        [lblVolume, lblPan, lblPanCaption, lblPanCaption2].forEach {$0.font = FontSets.systemFontSet.player.feedbackFont}
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)   // This call will also take care of toggle buttons.
        changeSliderColors()
        changeSliderValueTextColor(scheme.player.sliderValueTextColor)
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        
        btnVolume.reTint()
        
        lblPanCaption.textColor = color
        lblPanCaption2.textColor = color
    }
    
    private func changeSliderColors() {
        [volumeSlider, panSlider].forEach({$0?.redraw()})
    }
    
    private func changeSliderValueTextColor(_ color: NSColor) {
        
        lblVolume.textColor = Colors.Player.feedbackTextColor
        lblPan.textColor = Colors.Player.feedbackTextColor
    }
    
    private func trackChanged(_ newTrack: Track?) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if soundPreferences.rememberEffectsSettings, let theNewTrack = newTrack, soundProfiles.hasFor(theNewTrack) {

            volumeChanged(audioGraph.volume, audioGraph.muted)
            panChanged(audioGraph.balance)
        }
    }
    
    // MARK: Message handling
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
}
