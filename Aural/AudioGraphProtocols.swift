import Cocoa
import AVFoundation

/*
    Contract for operations to alter the audio graph, i.e. tune the sound output - volume, panning, equalizer (EQ), and sound effects
 */
protocol AudioGraphProtocol: EQUnitProtocol, PitchShiftUnitProtocol, TimeStretchUnitProtocol, ReverbUnitProtocol, DelayUnitProtocol, FilterUnitProtocol {
    
    func toggleMasterBypass() -> Bool
    
    func isMasterBypass() -> Bool
    
    func saveMasterPreset(_ presetName: String)
    
    func applyMasterPreset(_ preset: MasterPreset)
    
    func getSettingsAsMasterPreset() -> MasterPreset
    
    // Retrieves the current player volume
    func getVolume() -> Float
    
    // Sets the player volume, specified as a value between 0 and 1
    func setVolume(_ volume: Float)
    
    // Retrieves the current stereo L/R balance (aka pan)
    func getBalance() -> Float
    
    // Sets the stereo L/R balance (aka pan), specified as a value between -1 (L) and 1 (R)
    func setBalance(_ balance: Float)
    
    // Mutes the player
    func mute()
    
    // Unmutes the player
    func unmute()
    
    // Determines whether the player is currently muted
    func isMuted() -> Bool
    
    // Shuts down the audio graph, releasing all its resources
    func tearDown()
}

protocol EQUnitProtocol {
    
    func toggleEQSync() -> Bool
    
    func getEQType() -> EQType
    
    func getEQSync() -> Bool
    
    func chooseEQType(_ type: EQType)
    
    // Returns the current state of the Equalizer audio effects unit
    func getEQState() -> EffectsUnitState
    
    // Toggles the state of the Equalizer audio effects unit, and returns its new state
    func toggleEQState() -> EffectsUnitState
    
    // Retrieves the current gloabal gain value for the EQ
    func getEQGlobalGain() -> Float
    
    // Sets global gain (or preamp) for the EQ
    func setEQGlobalGain(_ gain: Float)
    
    // Retrieves all EQ band gains in a map of index -> gain
    func getEQBands() -> [Int: Float]
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    func setEQBand(_ index: Int, gain: Float)
    
    // Sets the gain values of multiple equalizer bands (when using an EQ preset)
    // The bands parameter is a mapping of index -> gain
    func setEQBands(_ bands: [Int: Float])
    
    // Increases the equalizer bass band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseBass(_ increment: Float) -> [Int: Float]
    
    // Decreases the equalizer bass band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseBass(_ decrement: Float) -> [Int: Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseMids(_ increment: Float) -> [Int: Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseMids(_ decrement: Float) -> [Int: Float]
    
    // Increases the equalizer treble band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseTreble(_ increment: Float) -> [Int: Float]
    
    // Decreases the equalizer treble band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseTreble(_ decrement: Float) -> [Int: Float]
    
    func saveEQPreset(_ presetName: String)
    
    func applyEQPreset(_ preset: EQPreset)
}

protocol PitchShiftUnitProtocol {
    
    // Returns the current state of the pitch shift audio effects unit
    func getPitchState() -> EffectsUnitState
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func togglePitchState() -> EffectsUnitState
    
    func getPitch() -> Float
    
    // Sets the pitch shift value, in cents, specified as a value between -2400 and 2400
    func setPitch(_ pitch: Float)
    
    // Retrieves the overlap value of the pitch shift audio effects unit
    func getPitchOverlap() -> Float
    
    // Sets the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    func setPitchOverlap(_ overlap: Float)
    
    func savePitchPreset(_ presetName: String)
    
    func applyPitchPreset(_ preset: PitchPreset)
}

protocol TimeStretchUnitProtocol {
    
    // Returns the current state of the time audio effects unit
    func getTimeState() -> EffectsUnitState
    
    // Toggles the state of the time audio effects unit, and returns its new state
    func toggleTimeState() -> EffectsUnitState
    
    // Returns the current state of the pitch shift option of the time audio effects unit
    func isTimePitchShift() -> Bool
    
    // Toggles the pitch shift option of the time audio effects unit, and returns its new state
    func toggleTimePitchShift() -> Bool
    
    // Returns the pitch offset of the time audio effects unit. If the pitch shift option of the unit is enabled, this value will range between -2400 and +2400 cents. It will be 0 otherwise (i.e. pitch unaltered).
    func getTimePitchShift() -> Float
    
    func getTimeStretchRate() -> Float
    
    // Sets the playback rate, specified as a value between 1/32 and 32
    func setTimeStretchRate(_ rate: Float)
    
    // Retrieves the overlap value of the time audio effects unit and a string representation of it
    func getTimeOverlap() -> Float
    
    // Sets the amount of overlap between segments of the input audio signal into the time effects unit, specified as a value between 3 and 32
    func setTimeOverlap(_ overlap: Float)
    
    func saveTimePreset(_ presetName: String)
    
    func applyTimePreset(_ preset: TimePreset)
}

protocol ReverbUnitProtocol {
    
    // Returns the current state of the reverb audio effects unit
    func getReverbState() -> EffectsUnitState
    
    // Toggles the state of the reverb audio effects unit, and returns its new state
    func toggleReverbState() -> EffectsUnitState
    
    func getReverbSpace() -> ReverbSpaces
    
    // Sets the reverb space. See ReverbSpaces for more details.
    func setReverbSpace(_ space: ReverbSpaces)
    
    func getReverbAmount() -> Float
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(_ amount: Float)
    
    func saveReverbPreset(_ presetName: String)
    
    func applyReverbPreset(_ preset: ReverbPreset)
}

protocol DelayUnitProtocol {
    
    // Returns the current state of the delay audio effects unit
    func getDelayState() -> EffectsUnitState
    
    // Toggles the state of the delay audio effects unit, and returns its new state
    func toggleDelayState() -> EffectsUnitState
    
    func getDelayAmount() -> Float
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(_ amount: Float)
    
    func getDelayTime() -> Double
    
    // Sets the delay time, in seconds, specified as a value between 0 and 2
    func setDelayTime(_ time: Double)
    
    func getDelayFeedback() -> Float
    
    // Sets the delay feedback, in percentage, specified as a value between -100 and 100
    func setDelayFeedback(_ percent: Float)
    
    func getDelayLowPassCutoff() -> Float
    
    // Sets the delay low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setDelayLowPassCutoff(_ cutoff: Float)
    
    func saveDelayPreset(_ presetName: String)
    
    func applyDelayPreset(_ preset: DelayPreset)
}

protocol FilterUnitProtocol {
 
    // Returns the current state of the filter audio effects unit
    func getFilterState() -> EffectsUnitState
    
    // Toggles the state of the filter audio effects unit, and returns its new state
    func toggleFilterState() -> EffectsUnitState
    
//    func getFilterBassBand() -> (min: Float, max: Float)
//
//    func getFilterMidBand() -> (min: Float, max: Float)
//
//    func getFilterTrebleBand() -> (min: Float, max: Float)
//
//    // Sets the bass band of the filter to the specified frequency range
//    func setFilterBassBand(_ min: Float, _ max: Float)
//
//    // Sets the mid band of the filter to the specified frequency range
//    func setFilterMidBand(_ min: Float, _ max: Float)
//
//    // Sets the treble band of the filter to the specified frequency range
//    func setFilterTrebleBand(_ min: Float, _ max: Float)
    
    func addFilterBand(_ band: FilterBand) -> Int
    
    func updateFilterBand(_ index: Int, _ band: FilterBand)
    
    func removeFilterBands(_ indexSet: IndexSet)
    
    func removeAllFilterBands()
    
    func allFilterBands() -> [FilterBand]
    
    func getFilterBand(_ index: Int) -> FilterBand
    
    func saveFilterPreset(_ presetName: String)
    
    func applyFilterPreset(_ preset: FilterPreset)
}

/*
    Contract for a sub-graph of the audio graph, suitable for a player, that performs operations on only the player node of the graph.
 */
protocol PlayerGraphProtocol {
    
    // The audio graph node responsible for playback
    var playerNode: AVAudioPlayerNode {get}
    
    // Reconnects the player node to its output node, with a new audio format
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat)
    
    // Clears reverb/delay sound tails. Suitable for use when stopping the player.
    func clearSoundTails()
    
    // When the audio output is changed
    func restartAudioEngine()
}

/*
    Contract for a sub-graph of the audio graph, suitable for a recorder, that has access to only the graph node on which a recorder tap can be installed.
 */
protocol RecorderGraphProtocol {
 
    // The audio graph node on which a recorder tap can be installed
    var nodeForRecorderTap: AVAudioNode {get}
}
