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
    
    // Sets the pitch shift value, in cents, specified as a value between -2400 and 2400
    func setPitch(pitch: Float)
    
    func setPitchOverlap(overlap: Float)
    
    // Sets the reverb preset. See ReverbPresets for more details.
    func setReverb(preset: ReverbPresets)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(amount: Float)
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(amount: Float)
}