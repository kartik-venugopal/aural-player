/*
    Contract for a middleman/delegate that relays all requests to alter the audio graph, i.e. to tune the sound output - volume, panning, equalizer (EQ), sound effects, etc
 */
import Cocoa

protocol AudioGraphDelegateProtocol: ReverbUnitDelegateProtocol, DelayUnitDelegateProtocol, FilterUnitDelegateProtocol {
    
    // NOTE - All functions that return String values return user-friendly text representations of the value being get/set, for display in the UI. For instance, setDelayLowPassCutoff(64) might return a value like "64 Hz"
    
    func toggleMasterBypass() -> Bool
    
    func isMasterBypass() -> Bool
    
    var masterPresets: MasterPresets {get}
    
    func saveMasterPreset(_ presetName: String)
    
    func applyMasterPreset(_ presetName: String)
    
    func applyMasterPreset(_ preset: MasterPreset)
    
    func getSettingsAsMasterPreset() -> MasterPreset
    
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
    
    var eqUnit: EQUnitDelegate {get set}
    var pitchUnit: PitchUnitDelegate {get set}
    var timeUnit: TimeUnitDelegate {get set}
}

protocol FXUnitDelegateProtocol {
    
    var state: EffectsUnitState {get}
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func toggleState() -> EffectsUnitState
    
    func ensureActive()
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ presetName: String)
}

protocol MasterUnitDelegateProtocol: FXUnitDelegateProtocol {}

protocol EQUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var type: EQType {get set}
    
    var globalGain: Float {get set}
    
    var bands: [Int: Float] {get set}
    
    var sync: Bool {get set}
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    func setBand(_ index: Int, gain: Float)
    
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

protocol PitchShiftUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    var pitch: Float {get set}
    
    var formattedPitch: String {get}
    
    // the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    var overlap: Float {get set}
    
    var formattedOverlap: String {get}
    
    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
    func increasePitch() -> (pitch: Float, pitchString: String)
    
    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
    func decreasePitch() -> (pitch: Float, pitchString: String)
}

protocol TimeStretchUnitDelegateProtocol: FXUnitDelegateProtocol {
    
    var rate: Float {get set}
    
    var formattedRate: String {get}
    
    var overlap: Float {get set}
    
    var formattedOverlap: String {get}
    
    var shiftPitch: Bool {get set}
    
    var pitch: Float {get}
    
    var formattedPitch: String {get}
    
    // Increases the playback rate by a small increment. Returns the new playback rate value.
    func increaseRate() -> (rate: Float, rateString: String)
    
    // Decreases the playback rate by a small decrement. Returns the new playback rate value.
    func decreaseRate() -> (rate: Float, rateString: String)
}

protocol ReverbUnitDelegateProtocol {
    
    // Returns the current state of the reverb audio effects unit
    func getReverbState() -> EffectsUnitState
    
    // Toggles the state of the reverb audio effects unit, and returns its new state
    func toggleReverbState() -> EffectsUnitState
    
    func getReverbSpace() -> ReverbSpaces
    
    // Sets the reverb space. See ReverbSpaces for more details.
    func setReverbSpace(_ space: ReverbSpaces)
    
    func getReverbAmount() -> (amount: Float, amountString: String)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(_ amount: Float) -> String
    
    var reverbPresets: ReverbPresets {get}
    
    func saveReverbPreset(_ presetName: String)
    
    func applyReverbPreset(_ presetName: String)
}

protocol DelayUnitDelegateProtocol {
    
    // Returns the current state of the delay audio effects unit
    func getDelayState() -> EffectsUnitState
    
    // Toggles the state of the delay audio effects unit, and returns its new state
    func toggleDelayState() -> EffectsUnitState
    
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
    
    var delayPresets: DelayPresets {get}
    
    func saveDelayPreset(_ presetName: String)
    
    func applyDelayPreset(_ presetName: String)
}

protocol FilterUnitDelegateProtocol {
 
    // Returns the current state of the filter audio effects unit
    func getFilterState() -> EffectsUnitState
    
    // Toggles the state of the filter audio effects unit, and returns its new state
    func toggleFilterState() -> EffectsUnitState
    
    func addFilterBand(_ band: FilterBand) -> Int
    
    func updateFilterBand(_ index: Int, _ band: FilterBand)
    
    func removeFilterBands(_ indexSet: IndexSet)
    
    func removeAllFilterBands()
    
    func allFilterBands() -> [FilterBand]
    
    func getFilterBand(_ index: Int) -> FilterBand
    
    var filterPresets: FilterPresets {get}
    
    func saveFilterPreset(_ presetName: String)
    
    func applyFilterPreset(_ presetName: String)
}
