/*
Contract for player-level operations to tune the sound of the player - volume, panning, equalizer (EQ) bands, sound effects.
*/
import Cocoa
import AVFoundation

protocol AuralSoundTuner {
    
    // Retrieves the current player volume
    func getVolume() -> Float
    
    // Sets the player volume, specified as a value between 0 and 1
    func setVolume(volume: Float)
    
    // Retrieves the current L/R balance (aka pan)
    func getBalance() -> Float
    
    // Sets the L/R balance (aka pan), specified as a value between -1 (L) and 1 (R)
    func setBalance(balance: Float)
    
    // Mutes the player
    func mute()
    
    // Unmutes the player
    func unmute()
    
    // Determines whether the player is currently muted
    func isMuted() -> Bool
    
    // Sets global gain (or preamp) for the equalizer
    func setEQGlobalGain(gain: Float)
    
    // Sets the gain value of a single equalizer frequency band
    func setEQBand(freq: Int , gain: Float)
    
    // Sets the gain values of multiple equalizer frequency bands (when using an EQ preset)
    func setEQBands(bands: [Int: Float])
    
    // Toggles the bypass state of the pitch shift audio effect unit, and returns its new bypass state
    func togglePitchBypass() -> Bool
    
    // Sets the pitch shift value, in cents, specified as a value between -2400 and 2400
    func setPitch(pitch: Float)
    
    // Sets the amount of overlap between segments of the input audio signal, specified as a value between 3 and 32
    func setPitchOverlap(overlap: Float)
    
    // Toggles the bypass state of the time audio effect unit, and returns its new bypass state
    func toggleTimeBypass() -> Bool
    
    // Sets the playback rate, specified as a value between 1/32 and 32
    func setTimeStretchRate(rate: Float)
    
    // Toggles the bypass state of the reverb audio effect unit, and returns its new bypass state
    func toggleReverbBypass() -> Bool
    
    // Sets the reverb preset. See ReverbPresets for more details.
    func setReverb(preset: ReverbPresets)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(amount: Float)
    
    // Toggles the bypass state of the delay audio effect unit, and returns its new bypass state
    func toggleDelayBypass() -> Bool
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(amount: Float)
    
    // Sets the delay time, in seconds, specified as a value between 0 and 2
    func setDelayTime(time: Double)
    
    // Sets the delay feedback, in percentage, specified as a value between -100 and 100
    func setDelayFeedback(percent: Float)

    // Sets the delay low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setDelayLowPassCutoff(cutoff: Float)
    
    // Toggles the bypass state of the filter audio effect unit, and returns its new bypass state
    func toggleFilterBypass() -> Bool
    
    // Sets the filter low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setFilterLowPassCutoff(cutoff: Float)
    
    // Sets the filter high pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setFilterHighPassCutoff(cutoff: Float)
}