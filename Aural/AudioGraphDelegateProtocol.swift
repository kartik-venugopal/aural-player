/*
    Contract for a middleman/facade, between the UI and the audio graph, that defines app-level (UI-level) operations to tune the sound of the audio player - volume, panning, equalizer (EQ) bands, sound effects.
 */
import Cocoa

protocol AudioGraphDelegateProtocol {
    
    // NOTE - All setter functions that return String values return user-friendly text representations of the value being set, for display in the UI. For instance, setDelayLowPassCutoff(64) might return a value like "64 Hz"
    
    // Retrieves the current player volume
    func getVolume() -> Float
    
    // Sets the player volume, specified as a percentage (0 to 100)
    func setVolume(_ volumePercentage: Float)
    
    // Increases the player volume by a small increment. Returns the new player volume.
    func increaseVolume() -> Float
    
    // Decreases the player volume by a small decrement. Returns the new player volume.
    func decreaseVolume() -> Float
    
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
    
    // Sets global gain (or preamp) for the equalizer
    func setEQGlobalGain(_ gain: Float)
    
    // Sets the gain value of a single equalizer frequency band.
    func setEQBand(_ frequency: Int, gain: Float)
    
    // Sets the gain values of multiple equalizer frequency bands (when using an EQ preset)
    func setEQBands(_ bands: [Int: Float])
    
    // Toggles the bypass state of the pitch shift audio effect unit, and returns its new bypass state
    func togglePitchBypass() -> Bool
    
    // Sets the pitch shift value, in octaves, specified as a value between -2 and 2
    func setPitch(_ pitch: Float) -> String
    
    // Sets the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    func setPitchOverlap(_ overlap: Float) -> String
    
    // Toggles the bypass state of the time audio effect unit, and returns its new bypass state
    func toggleTimeBypass() -> Bool
    
    // Returns the current bypass state of the time audio effect unit
    func isTimeBypass() -> Bool
    
    // Sets the playback rate, specified as a value between 1/32 and 32
    func setTimeStretchRate(_ rate: Float) -> String
    
    // Sets the amount of overlap between segments of the input audio signal into the time effects unit, specified as a value between 3 and 32
    func setTimeOverlap(_ overlap: Float) -> String
    
    // Toggles the bypass state of the reverb audio effect unit, and returns its new bypass state
    func toggleReverbBypass() -> Bool
    
    // Sets the reverb preset. See ReverbPresets for more details.
    func setReverb(_ preset: ReverbPresets)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(_ amount: Float) -> String
    
    // Toggles the bypass state of the delay audio effect unit, and returns its new bypass state
    func toggleDelayBypass() -> Bool
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(_ amount: Float) -> String
    
    // Sets the delay time, in seconds, specified as a value between 0 and 2
    func setDelayTime(_ time: Double) -> String
    
    // Sets the delay feedback, in percentage, specified as a value between -100 and 100
    func setDelayFeedback(_ percent: Float) -> String
    
    // Sets the delay low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setDelayLowPassCutoff(_ cutoff: Float) -> String
    
    // Toggles the bypass state of the filter audio effect unit, and returns its new bypass state
    func toggleFilterBypass() -> Bool
    
    // Sets the bass band of the filter to the specified frequency range
    func setFilterBassBand(_ min: Float, _ max: Float) -> String
    
    // Sets the mid band of the filter to the specified frequency range
    func setFilterMidBand(_ min: Float, _ max: Float) -> String
    
    // Sets the treble band of the filter to the specified frequency range
    func setFilterTrebleBand(_ min: Float, _ max: Float) -> String
}
