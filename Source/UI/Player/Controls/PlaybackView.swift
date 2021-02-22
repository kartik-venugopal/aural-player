import Cocoa

/*
    View that encapsulates all playback-related controls (play/pause, prev/next track, seeking, segment looping).
*/
class PlaybackView: NSView, ColorSchemeable {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var sliderView: SeekSliderView!
   
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: OnOffImageButton!
    @IBOutlet weak var btnLoop: MultiStateImageButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: TrackPeekingButton!
    @IBOutlet weak var btnNextTrack: TrackPeekingButton!
    
    @IBOutlet weak var btnSeekBackward: NSButton!
    @IBOutlet weak var btnSeekForward: NSButton!
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let sequencer: SequencerInfoDelegateProtocol = ObjectGraph.sequencerInfoDelegate
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    var seekSliderValue: Double {
        return sliderView.seekSliderValue
    }
    
    override func awakeFromNib() {
        
        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)

        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnLoop.stateImageMappings = [(LoopState.none, (Images.imgLoopOff, offStateTintFunction)), (LoopState.started, (Images.imgLoopStarted, onStateTintFunction)), (LoopState.complete, (Images.imgLoopComplete, onStateTintFunction))]

        // Play/pause button does not really have an "off" state
        btnPlayPause.offStateTintFunction = onStateTintFunction
        
        // Button tool tips
        btnPreviousTrack.toolTipFunction = {
            () -> String? in

            if let prevTrack = self.sequencer.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.conciseDisplayName)
            }

            return nil
        }

        btnNextTrack.toolTipFunction = {
            () -> String? in

            if let nextTrack = self.sequencer.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.conciseDisplayName)
            }

            return nil
        }

        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
        
        applyFontScheme(FontSchemes.systemFontScheme)
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        
        btnPlayPause.onIf(newState == .playing)
        sliderView.playbackStateChanged(newState)
    }

    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {

        // Update loop button image
        if let loop = playbackLoop {
            btnLoop.switchState(loop.isComplete ? LoopState.complete: LoopState.started)

        } else {
            btnLoop.switchState(LoopState.none)
        }
        
        sliderView.playbackLoopChanged(playbackLoop, trackDuration)
    }

    func trackChanged(_ playbackState: PlaybackState, _ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        btnPlayPause.onIf(playbackState == .playing)
        btnLoop.switchState(loop != nil ? LoopState.complete : LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
        
        sliderView.trackChanged(loop, newTrack)
    }
    
    func transcodingStarted() {

        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
        
        sliderView.transcodingStarted()
    }

    func showOrHideTimeElapsedRemaining() {
        sliderView.showOrHideTimeElapsedRemaining()
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        sliderView.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        // This call will also take care of toggle buttons
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        sliderView.applyColorScheme(scheme)
    }
    
    func changeSliderColors() {
        sliderView.changeSliderColors()
    }
    
    func changeSliderValueTextColor(_ color: NSColor) {
        sliderView.changeSliderValueTextColor(color)
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        // TODO: Put these buttons in an array on initialization and refer to the array here
        
        [btnLoop, btnPlayPause, btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward].forEach({
            ($0 as? Tintable)?.reTint()
        })
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
        
        // Only these buttons have off states that look different from their on states
        btnLoop.reTint()
    }
    
    // Positions the "seek position marker" view at the center of the seek slider knob.
    func positionSeekPositionMarkerView() {
        sliderView.positionSeekPositionMarkerView()
    }
    
    func updateSeekPosition() {
        sliderView.updateSeekPosition()
    }
    
    var seekPositionMarker: NSView! {
        return sliderView.seekPositionMarker
    }
    
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        sliderView.playbackRateChanged(rate, playbackState)
    }
    
    func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        sliderView.setTimeElapsedDisplayFormat(format)
    }
    
    func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        sliderView.setTimeRemainingDisplayFormat(format)
    }
}
