/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerControlsViewController: NSViewController, ActionMessageSubscriber {
    
    @IBOutlet weak var controlsView: PlayerControlsView!
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    override var nibName: String? {return "PlayerControls"}
    
    override func viewDidLoad() {

        let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
        let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
        let timeUnit: TimeUnitDelegateProtocol = audioGraph.timeUnit
        
        let playbackRate = timeUnit.isActive ? timeUnit.rate : Float(1.0)
        let rsModes = player.repeatAndShuffleModes
        
        controlsView.initialize(audioGraph.volume, audioGraph.muted, audioGraph.balance, player.state, playbackRate, rsModes.repeatMode, rsModes.shuffleMode, seekPositionFunction: {() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) in return player.seekPosition })
        
        controlsView.changeTextSize(PlayerViewState.textSize)
        controlsView.applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(actionTypes: [.showOrHideTimeElapsedRemaining, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat, .changePlayerTextSize, .applyColorScheme, .changeFunctionButtonColor, .changeToggleButtonOffStateColor, .changePlayerSliderValueTextColor, .changePlayerSliderColors], subscriber: self)
    }
    
    // Returns a view that marks the current position of the seek slider knob.
    var seekPositionMarkerView: NSView {
        
        controlsView.positionSeekPositionMarkerView()
        return controlsView.seekPositionMarker
    }
    
    private func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        
        PlayerViewState.timeElapsedDisplayType = format
        controlsView.setTimeElapsedDisplayFormat(format)
    }
    
    private func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        
        PlayerViewState.timeRemainingDisplayType = format
        controlsView.setTimeRemainingDisplayFormat(format)
    }
    
    private func showOrHideTimeElapsedRemaining() {
        
        PlayerViewState.showTimeElapsedRemaining = !PlayerViewState.showTimeElapsedRemaining
        controlsView.showOrHideTimeElapsedRemaining()
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        // Player functions
            
        case .changePlayerTextSize:
                
            controlsView.changeTextSize(PlayerViewState.textSize)
            
        case .applyColorScheme:
                
            if let scheme = (message as? ColorSchemeActionMessage)?.scheme {
                controlsView.applyColorScheme(scheme)
            }
            
        case .setTimeElapsedDisplayFormat:

            if let format = (message as? SetTimeElapsedDisplayFormatActionMessage)?.format {
                setTimeElapsedDisplayFormat(format)
            }

        case .setTimeRemainingDisplayFormat:

            if let format = (message as? SetTimeRemainingDisplayFormatActionMessage)?.format {
                setTimeRemainingDisplayFormat(format)
            }

        case .showOrHideTimeElapsedRemaining:

            showOrHideTimeElapsedRemaining()
            
        default:
            
            if let colorSchemeMsg = message as? ColorSchemeComponentActionMessage {

                switch colorSchemeMsg.actionType {

                case .changeFunctionButtonColor:

                    controlsView.changeFunctionButtonColor(colorSchemeMsg.color)

                case .changeToggleButtonOffStateColor:

                    controlsView.changeToggleButtonOffStateColor(colorSchemeMsg.color)

                case .changePlayerSliderValueTextColor:

                    controlsView.changeSliderValueTextColor()

                case .changePlayerSliderColors:

                    controlsView.changeSliderColors()

                default: return

                }
            }
        }
    }
}
