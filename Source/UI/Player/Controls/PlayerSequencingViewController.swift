/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerSequencingViewController: NSViewController, ActionMessageSubscriber {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let playbackSequence: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.playbackSequencerInfoDelegate
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    override func viewDidLoad() {
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(ObjectGraph.playbackDelegate.repeatAndShuffleModes)
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn], subscriber: self)
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(player.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(player.toggleShuffleMode())
    }
    
    // Sets the repeat mode to "Off"
    private func repeatOff() {
        updateRepeatAndShuffleControls(player.setRepeatMode(.off))
    }
    
    // Sets the repeat mode to "Repeat One"
    private func repeatOne() {
        updateRepeatAndShuffleControls(player.setRepeatMode(.one))
    }
    
    // Sets the repeat mode to "Repeat All"
    private func repeatAll() {
        updateRepeatAndShuffleControls(player.setRepeatMode(.all))
    }
    
    // Sets the shuffle mode to "Off"
    private func shuffleOff() {
        updateRepeatAndShuffleControls(player.setShuffleMode(.off))
    }
    
    // Sets the shuffle mode to "On"
    private func shuffleOn() {
        updateRepeatAndShuffleControls(player.setShuffleMode(.on))
    }
    
    func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
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
        
        default: return
            
        }
    }
}
