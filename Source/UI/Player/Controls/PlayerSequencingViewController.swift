/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerSequencingViewController: NSViewController, ActionMessageSubscriber {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    private let sequencer: PlaybackSequencerDelegateProtocol = ObjectGraph.playbackSequencerDelegate
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    override func viewDidLoad() {
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(ObjectGraph.playbackDelegate.repeatAndShuffleModes)
        
        applyColorScheme(ColorSchemes.systemScheme)
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn, .applyColorScheme, .changeFunctionButtonColor, .changeToggleButtonOffStateColor], subscriber: self)
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    // Sets the repeat mode to "Off"
    private func repeatOff() {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(.off))
    }
    
    // Sets the repeat mode to "Repeat One"
    private func repeatOne() {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(.one))
    }
    
    // Sets the repeat mode to "Repeat All"
    private func repeatAll() {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(.all))
    }
    
    // Sets the shuffle mode to "Off"
    private func shuffleOff() {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(.off))
    }
    
    // Sets the shuffle mode to "On"
    private func shuffleOn() {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(.on))
    }
    
    private func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
    
    private func changeFunctionButtonColor() {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
    
    private func changeToggleButtonOffStateColor() {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
      
        case .repeatOff: repeatOff()
            
        case .repeatOne: repeatOne()
            
        case .repeatAll: repeatAll()
            
        case .shuffleOff: shuffleOff()
            
        case .shuffleOn: shuffleOn()
            
        case .applyColorScheme:
            
            if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
                applyColorScheme(colorSchemeActionMsg.scheme)
            }
                
        case .changeFunctionButtonColor:
               
            changeFunctionButtonColor()
            
        case .changeToggleButtonOffStateColor:
            
            changeToggleButtonOffStateColor()
        
        default: return
            
        }
    }
}
