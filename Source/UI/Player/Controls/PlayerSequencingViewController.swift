/*
    View controller for playback sequencing controls (repeat/shuffle).
    Also handles sequencing requests from app menus.
 */
import Cocoa

class PlayerSequencingViewController: NSViewController, ActionMessageSubscriber {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    private let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    override func viewDidLoad() {
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        
        redrawButtons()
        
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
    
    private func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
    
    private func redrawButtons() {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
    
    // MARK: Message handling

    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
      
        case .repeatOff:
            
            updateRepeatAndShuffleControls(sequencer.setRepeatMode(.off))
            
        case .repeatOne:
            
            updateRepeatAndShuffleControls(sequencer.setRepeatMode(.one))
            
        case .repeatAll:
            
            updateRepeatAndShuffleControls(sequencer.setRepeatMode(.all))
            
        case .shuffleOff:
            
            updateRepeatAndShuffleControls(sequencer.setShuffleMode(.off))
            
        case .shuffleOn:
            
            updateRepeatAndShuffleControls(sequencer.setShuffleMode(.on))
            
        case .applyColorScheme, .changeFunctionButtonColor, .changeToggleButtonOffStateColor:
            
            redrawButtons()
        
        default: return
            
        }
    }
}
