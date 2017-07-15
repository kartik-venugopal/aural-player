/*
    Contract for a middleman/facade, between the UI and the player, that defines app-level (UI-level) operations to tune the sound of the audio player - volume, panning, equalizer (EQ) bands, sound effects.
*/
import Cocoa

protocol AuralSoundTuningDelegate {
    
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

    // Sets the L/R balance (aka pan), specified as a value between -1 (L) and 1 (R)
    func setBalance(_ balance: Float)
    
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
    func setPitch(_ pitch: Float)

    func setPitchOverlap(_ overlap: Float)
    
    // Toggles the bypass state of the time audio effect unit, and returns its new bypass state
    func toggleTimeBypass() -> Bool
    
    // Sets the playback rate, specified as a value between 1/32 and 32
    func setTimeStretchRate(_ rate: Float)
    
    // Toggles the bypass state of the reverb audio effect unit, and returns its new bypass state
    func toggleReverbBypass() -> Bool
    
    // Sets the reverb preset. See ReverbPresets for more details.
    func setReverb(_ preset: ReverbPresets)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(_ amount: Float)
    
    // Toggles the bypass state of the delay audio effect unit, and returns its new bypass state
    func toggleDelayBypass() -> Bool
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(_ amount: Float)
    
    // Sets the delay time, in seconds, specified as a value between 0 and 2
    func setDelayTime(_ time: Double)
    
    // Sets the delay feedback, in percentage, specified as a value between -100 and 100
    func setDelayFeedback(_ percent: Float)
    
    // Sets the delay low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setDelayLowPassCutoff(_ cutoff: Float)
    
    // Toggles the bypass state of the filter audio effect unit, and returns its new bypass state
    func toggleFilterBypass() -> Bool
    
    // Sets the filter low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setFilterLowPassCutoff(_ cutoff: Float)
    
    // Sets the filter high pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setFilterHighPassCutoff(_ cutoff: Float)
}
