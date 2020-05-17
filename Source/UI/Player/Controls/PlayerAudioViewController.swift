/*
    View controller for player volume and pan
 */
import Cocoa

class PlayerAudioViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: TintedImageButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblVolume: VALabel!
    @IBOutlet weak var lblPan: VALabel!
    @IBOutlet weak var lblPanCaption: VALabel!
    @IBOutlet weak var lblPanCaption2: VALabel!
    
    // TODO - Revisit AutoHidingView
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    private var autoHidingVolumeLabel: AutoHidingView!
    private var autoHidingPanLabel: AutoHidingView!
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    private let soundPreferences: SoundPreferences = ObjectGraph.preferencesDelegate.preferences.soundPreferences
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    override func viewDidLoad() {
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        autoHidingPanLabel = AutoHidingView(lblPan, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        
        volumeSlider.floatValue = audioGraph.volume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        panSlider.floatValue = audioGraph.balance
        panChanged(audioGraph.balance, false)
        
        changeTextSize(PlayerViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)

        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .changePlayerTextSize, .applyColorScheme, .changeFunctionButtonColor, .changePlayerSliderColors, .changePlayerSliderValueTextColor], subscriber: self)
    }
    
    // Updates the volume
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.volume = volumeSlider.floatValue
        volumeChanged(audioGraph.volume, audioGraph.muted, false)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        
        audioGraph.muted = !audioGraph.muted
        updateVolumeMuteButtonImage(audioGraph.volume, audioGraph.muted)
    }
    
    // Decreases the volume by a certain preset decrement
    private func decreaseVolume(_ actionMode: ActionMode) {
        
        let newVolume = audioGraph.decreaseVolume(actionMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    private func increaseVolume(_ actionMode: ActionMode) {
        
        let newVolume = audioGraph.increaseVolume(actionMode)
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
            if (volume > 200/3) {
                btnVolume.baseImage = Images.imgVolumeHigh
                
            } else if (volume > 100/3) {
                btnVolume.baseImage = Images.imgVolumeMedium
                
            } else if (volume > 0) {
                btnVolume.baseImage = Images.imgVolumeLow
                
            } else {
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
    
    private func changeTextSize(_ size: TextSize) {
        [lblVolume, lblPan, lblPanCaption, lblPanCaption2].forEach({$0.font = Fonts.Player.feedbackFont})
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)   // This call will also take care of toggle buttons.
        changeSliderColors()
        changeSliderValueTextColor()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        
        btnVolume.reTint()
        
        lblPanCaption.textColor = color
        lblPanCaption2.textColor = color
    }
    
    private func changeSliderColors() {
        [volumeSlider, panSlider].forEach({$0?.redraw()})
    }
    
    private func changeSliderValueTextColor() {
        
        lblVolume.textColor = Colors.Player.feedbackTextColor
        lblPan.textColor = Colors.Player.feedbackTextColor
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ oldTrack: Track?, _ newTrack: Track?) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if soundPreferences.rememberEffectsSettings, let track = newTrack, soundProfiles.hasFor(track) {

            volumeChanged(audioGraph.volume, audioGraph.muted)
            panChanged(audioGraph.balance)
        }
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
     
        if let trackChangedMsg = notification as? TrackChangedNotification {
            
            trackChanged(trackChangedMsg.oldTrack, trackChangedMsg.newTrack)
            return
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .muteOrUnmute:
            
            muteOrUnmuteAction(self)
            
        case .decreaseVolume:
            
            if let actionMode = (message as? AudioGraphActionMessage)?.actionMode {
                decreaseVolume(actionMode)
            }
            
        case .increaseVolume:
            
            if let actionMode = (message as? AudioGraphActionMessage)?.actionMode {
                increaseVolume(actionMode)
            }
            
        case .panLeft:
            
            panLeft()
            
        case .panRight:
            
            panRight()
            
        case .changePlayerTextSize:
            
            if let textSizeMsg = message as? TextSizeActionMessage {
                changeTextSize(textSizeMsg.textSize)
            }
            
        case .applyColorScheme:
            
            if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
                applyColorScheme(colorSchemeActionMsg.scheme)
            }
            
        case .changeFunctionButtonColor:
            
            if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
                
                changeFunctionButtonColor(colorComponentActionMsg.color)
                return
            }
            
        case .changePlayerSliderColors:
            
            changeSliderColors()
            
        case .changePlayerSliderValueTextColor:
            
            changeSliderValueTextColor()
            
        default: return

        }
    }
}
