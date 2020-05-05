/*
    View controller that handles the assembly of the player view tree from its multiple pieces, and handles general concerns for the view such as text size and color scheme changes.
 
    The player view tree consists of:
        
        - Playing track info (track info, art, etc)
            - Default view
            - Expanded Art view
 
        - Transcoder info (when a track is being transcoded)
 
        - Player controls (play/seek, next/previous track, repeat/shuffle, volume/balance)
 */
import Cocoa

// TODO: Merge this with TrackInfoViewController
class PlayerViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playerView: NSView!
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
    @IBOutlet weak var controlsView: PlayerControlsView!
    
    @IBOutlet weak var transcoderView: TranscoderView!
    
    @IBOutlet weak var playingTrackFunctionsView: PlayingTrackFunctionsView!
    
    private var colorSchemeables: [ColorSchemeable] = []
    private var textSizeables: [TextSizeable] = []
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {
        
        playerView.addSubview(defaultView)
        playerView.addSubview(expandedArtView)
        
        self.view.addSubview(playerView)
        self.view.addSubview(transcoderView)
        
        defaultView.setFrameOrigin(NSPoint.zero)
        expandedArtView.setFrameOrigin(NSPoint.zero)
        transcoderView.setFrameOrigin(NSPoint.zero)
        
        textSizeables = [defaultView, expandedArtView, transcoderView, controlsView]
        changeTextSize()
        
        colorSchemeables = [defaultView, expandedArtView, transcoderView, controlsView, playingTrackFunctionsView]
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(actionTypes: [.applyColorScheme, .changePlayerTextSize, .changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor, .changePlayerTrackInfoTertiaryTextColor, .changeFunctionButtonColor, .changeToggleButtonOffStateColor, .changePlayerSliderValueTextColor, .changePlayerSliderColors, .changeTextButtonMenuColor, .changeButtonMenuTextColor], subscriber: self)
    }
    
    func changeTextSize() {
        textSizeables.forEach({$0.changeTextSize(PlayerViewState.textSize)})
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        colorSchemeables.forEach({$0.applyColorScheme(scheme)})
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        defaultView.changeBackgroundColor(color)
        expandedArtView.changeBackgroundColor(color)
        transcoderView.changeBackgroundColor(color)
    }
    
    private func changePrimaryTextColor(_ color: NSColor) {
        
        defaultView.changePrimaryTextColor(color)
        expandedArtView.changePrimaryTextColor(color)
        transcoderView.changePrimaryTextColor()
    }
    
    private func changeSecondaryTextColor(_ color: NSColor) {
        
        defaultView.changeSecondaryTextColor(color)
        expandedArtView.changeSecondaryTextColor(color)
        transcoderView.changeSecondaryTextColor()
    }
    
    private func changeTertiaryTextColor(_ color: NSColor) {
        
        defaultView.changeTertiaryTextColor(color)
        expandedArtView.changeTertiaryTextColor(color)
        transcoderView.changeTertiaryTextColor()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        
        controlsView.changeFunctionButtonColor(color)
        transcoderView.changeFunctionButtonColor(color)
        playingTrackFunctionsView.changeFunctionButtonColor(color)
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {

        controlsView.changeToggleButtonOffStateColor(color)
        playingTrackFunctionsView.changeToggleButtonOffStateColor(color)
    }
    
    private func changeSliderValueTextColor(_ color: NSColor) {
        
        controlsView.changeSliderValueTextColor()
        transcoderView.changeSliderValueTextColor()
    }
    
    private func changeSliderColors() {
        
        controlsView.changeSliderColors()
        transcoderView.changeSliderColors()
    }
    
    private func changeTextButtonMenuColor() {
        transcoderView.changeTextButtonColor()
    }
    
    private func changeButtonMenuTextColor() {
        transcoderView.changeButtonTextColor()
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .changePlayerTextSize:
            
            changeTextSize()
            
        case .applyColorScheme:
            
            if let scheme = (message as? ColorSchemeActionMessage)?.scheme {
                applyColorScheme(scheme)
            }
            
        default:
            
            if let colorSchemeMsg = message as? ColorSchemeComponentActionMessage {
                
                switch colorSchemeMsg.actionType {
                    
                case .changeBackgroundColor:
                    
                    changeBackgroundColor(colorSchemeMsg.color)
                    
                case .changePlayerTrackInfoPrimaryTextColor:
                    
                    changePrimaryTextColor(colorSchemeMsg.color)
                    
                case .changePlayerTrackInfoSecondaryTextColor:
                    
                    changeSecondaryTextColor(colorSchemeMsg.color)
                    
                case .changePlayerTrackInfoTertiaryTextColor:
                    
                    changeTertiaryTextColor(colorSchemeMsg.color)
                        
                case .changeFunctionButtonColor:
                    
                    changeFunctionButtonColor(colorSchemeMsg.color)
                    
                case .changeToggleButtonOffStateColor:
                    
                    changeToggleButtonOffStateColor(colorSchemeMsg.color)
                    
                case .changePlayerSliderValueTextColor:
                    
                    changeSliderValueTextColor(colorSchemeMsg.color)
                    
                case .changePlayerSliderColors:
                    
                    changeSliderColors()
                    
                case .changeTextButtonMenuColor:
                    
                    changeTextButtonMenuColor()
                    
                case .changeButtonMenuTextColor:
                    
                    changeButtonMenuTextColor()
                    
                default: return
                    
                }
            }
            
            return
        }
    }
}
