/*
    Contract for a middleman/delegate that relays all requests to alter the audio graph, i.e. to tune the sound output - volume, panning, equalizer (EQ), sound effects, etc
 */
import Cocoa

// TODO: Separate into separate protocols per effects unit
protocol AudioGraphDelegateProtocol: EQUnitDelegateProtocol, PitchShiftUnitDelegateProtocol, TimeStretchUnitDelegateProtocol, ReverbUnitDelegateProtocol, DelayUnitDelegateProtocol, FilterUnitDelegateProtocol {
    
    func toggleMasterBypass() -> Bool
    
    func isMasterBypass() -> Bool
    
    // NOTE - All functions that return String values return user-friendly text representations of the value being get/set, for display in the UI. For instance, setDelayLowPassCutoff(64) might return a value like "64 Hz"
    
    // Retrieves the current player volume
    func getVolume() -> Float
    
    // Sets the player volume, specified as a percentage (0 to 100)
    func setVolume(_ volumePercentage: Float)
    
    /*
        Increases the player volume by a small increment. Returns the new player volume.
     
        The "actionMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The action mode will affect the amount by which the volume is increased.
     */
    func increaseVolume(_ actionMode: ActionMode) -> Float
    
    /*
        Decreases the player volume by a small decrement. Returns the new player volume.
     
        The "actionMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The action mode will affect the amount by which the volume is decreased.
     */
    func decreaseVolume(_ actionMode: ActionMode) -> Float
    
    // Toggles mute between on/off. Returns true if muted after method execution, false otherwise
    func toggleMute() -> Bool
    
    // Determines whether player is currently muted
    func isMuted() -> Bool
    
    // Retrieves the current L/R balance (aka pan)
    func getBalance() -> Float
    
    // Sets the L/R balance (aka pan), specified as a percentage value between -100 (L) and 100 (R)
    func setBalance(_ balancePercentage: Float)
    
    // Pans left by a small increment. Returns new balance value.
    func panLeft() -> Float
    
    // Pans right by a small increment. Returns new balance value.
    func panRight() -> Float
}

protocol EQUnitDelegateProtocol {
    
    // Returns the current state of the Equalizer audio effects unit
    func getEQState() -> EffectsUnitState
    
    // Toggles the state of the Equalizer audio effects unit, and returns its new state
    func toggleEQState() -> EffectsUnitState
    
    // Retrieves the current gloabal gain value for the EQ
    func getEQGlobalGain() -> Float
    
    // Retrieves all EQ band gains in a map of index -> gain
    func getEQBands() -> [Int: Float]
    
    // Sets global gain (or preamp) for the equalizer
    func setEQGlobalGain(_ gain: Float)
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    func setEQBand(_ index: Int, gain: Float)
    
    // Sets the gain values of multiple equalizer bands (when using an EQ preset)
    // The bands parameter is a mapping of index -> gain
    func setEQBands(_ bands: [Int: Float])
    
    // Increases the equalizer bass band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func increaseBass() -> [Int: Float]
    
    // Decreases the equalizer bass band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func decreaseBass() -> [Int: Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func increaseMids() -> [Int: Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func decreaseMids() -> [Int: Float]
    
    // Increases the equalizer treble band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func increaseTreble() -> [Int: Float]
    
    // Decreases the equalizer treble band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    func decreaseTreble() -> [Int: Float]
}

protocol PitchShiftUnitDelegateProtocol {
    
    // Returns the current state of the pitch shift audio effects unit
    func getPitchState() -> EffectsUnitState
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func togglePitchState() -> EffectsUnitState
    
    // Retrieves the pitch shift value and a formatted string representation of it
    func getPitch() -> (pitch: Float, pitchString: String)
    
    // Sets the pitch shift value, in octaves, specified as a value between -2 and 2
    func setPitch(_ pitch: Float) -> String
    
    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
    func increasePitch() -> (pitch: Float, pitchString: String)
    
    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
    func decreasePitch() -> (pitch: Float, pitchString: String)
    
    // Retrieves the overlap value of the pitch shift audio effects unit and a string representation of it
    func getPitchOverlap() -> (overlap: Float, overlapString: String)
    
    // Sets the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    func setPitchOverlap(_ overlap: Float) -> String
}

protocol TimeStretchUnitDelegateProtocol {
    
    // Returns the current state of the time audio effects unit
    func getTimeState() -> EffectsUnitState
    
    // Toggles the state of the time audio effects unit, and returns its new state
    func toggleTimeState() -> EffectsUnitState
    
    // Returns the current state of the pitch shift option of the time audio effects unit
    func isTimePitchShift() -> Bool
    
    // Toggles the pitch shift option of the time audio effects unit, and returns its new state
    func toggleTimePitchShift() -> Bool
    
    // Retrieves the current playback rate value and a formatted string representation of it
    func getTimeRate() -> (rate: Float, rateString: String)
    
    // Returns the pitch offset of the time audio effects unit, as a user-friendly string. If the pitch shift option of the unit is enabled, this value will range between -2 and +2 octaves. It will be 0 otherwise (i.e. pitch unaltered).
    func getTimePitchShift() -> String
    
    // Sets the playback rate, specified as a value between 1/32 and 32
    func setTimeStretchRate(_ rate: Float) -> String
    
    // Increases the playback rate by a small increment. Returns the new playback rate value.
    func increaseRate() -> (rate: Float, rateString: String)
    
    // Decreases the playback rate by a small decrement. Returns the new playback rate value.
    func decreaseRate() -> (rate: Float, rateString: String)
    
    // Retrieves the overlap value of the time audio effects unit and a string representation of it
    func getTimeOverlap() -> (overlap: Float, overlapString: String)
    
    // Sets the amount of overlap between segments of the input audio signal into the time effects unit, specified as a value between 3 and 32
    func setTimeOverlap(_ overlap: Float) -> String
}

protocol ReverbUnitDelegateProtocol {
    
    // Returns the current state of the reverb audio effects unit
    func getReverbState() -> EffectsUnitState
    
    // Toggles the state of the reverb audio effects unit, and returns its new state
    func toggleReverbState() -> EffectsUnitState
    
    func getReverbSpace() -> String
    
    // Sets the reverb space. See ReverbSpaces for more details.
    func setReverbSpace(_ space: ReverbSpaces)
    
    func getReverbAmount() -> (amount: Float, amountString: String)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(_ amount: Float) -> String
}

protocol DelayUnitDelegateProtocol {
    
    // Returns the current bypass state of the delay audio effects unit
    func isDelayBypass() -> Bool
    
    // Toggles the bypass state of the delay audio effect unit, and returns its new bypass state
    func toggleDelayBypass() -> Bool
    
    func getDelayAmount() -> (amount: Float, amountString: String)
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(_ amount: Float) -> String
    
    func getDelayTime() -> (time: Double, timeString: String)
    
    // Sets the delay time, in seconds, specified as a value between 0 and 2
    func setDelayTime(_ time: Double) -> String
    
    func getDelayFeedback() -> (percent: Float, percentString: String)
    
    // Sets the delay feedback, in percentage, specified as a value between -100 and 100
    func setDelayFeedback(_ percent: Float) -> String
    
    func getDelayLowPassCutoff() -> (cutoff: Float, cutoffString: String)
    
    // Sets the delay low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setDelayLowPassCutoff(_ cutoff: Float) -> String
}

protocol FilterUnitDelegateProtocol {
 
    // Returns the current bypass state of the filter audio effects unit
    func isFilterBypass() -> Bool
    
    // Toggles the bypass state of the filter audio effect unit, and returns its new bypass state
    func toggleFilterBypass() -> Bool
    
    func getFilterBassBand() -> (min: Float, max: Float, rangeString: String)
    
    func getFilterMidBand() -> (min: Float, max: Float, rangeString: String)
    
    func getFilterTrebleBand() -> (min: Float, max: Float, rangeString: String)
    
    // Sets the bass band of the filter to the specified frequency range
    func setFilterBassBand(_ min: Float, _ max: Float) -> String
    
    // Sets the mid band of the filter to the specified frequency range
    func setFilterMidBand(_ min: Float, _ max: Float) -> String
    
    // Sets the treble band of the filter to the specified frequency range
    func setFilterTrebleBand(_ min: Float, _ max: Float) -> String
}
