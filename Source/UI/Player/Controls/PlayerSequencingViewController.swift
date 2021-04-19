/*
    View controller for playback sequencing controls (repeat/shuffle).
    Also handles sequencing requests from app menus.
 */
import Cocoa

class PlayerSequencingViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    private let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    override func viewDidLoad() {
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        
        redrawButtons()
        
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        Messenger.subscribe(self, .player_setRepeatMode, self.setRepeatMode(_:))
        Messenger.subscribe(self, .player_setShuffleMode, self.setShuffleMode(_:))
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, self.changeToggleButtonOffStateColor(_:))
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    private func setRepeatMode(_ repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(repeatMode))
    }
    
    private func setShuffleMode(_ shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(shuffleMode))
    }
    
    private func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
    
    private func applyTheme() {
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        redrawButtons()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func redrawButtons() {
        [btnRepeat, btnShuffle].forEach({$0.reTint()})
    }
}
