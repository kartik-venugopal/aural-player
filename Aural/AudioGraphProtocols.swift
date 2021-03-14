import Cocoa
import AVFoundation

/*
    Contract for operations to alter the audio graph, i.e. tune the sound output - volume, panning, equalizer (EQ), and other sound effects
 */
protocol AudioGraphProtocol: PlayerGraphProtocol, RecorderGraphProtocol {
    
    var volume: Float {get set}
    var balance: Float {get set}
    var muted: Bool {get set}
    
    var masterUnit: MasterUnit {get set}
    var eqUnit: EQUnit {get set}
    var pitchUnit: PitchUnit {get set}
    var timeUnit: TimeUnit {get set}
    var reverbUnit: ReverbUnit {get set}
    var delayUnit: DelayUnit {get set}
    var filterUnit: FilterUnit {get set}
    
    func getSettingsAsMasterPreset() -> MasterPreset
    
    var soundProfiles: SoundProfiles {get set}
    
    // Shuts down the audio graph, releasing all its resources
    func tearDown()
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
