import Foundation

class HostedAudioUnitDelegate: FXUnitDelegate<HostedAudioUnit>, HostedAudioUnitDelegateProtocol {
    
    var presets: AudioUnitPresets {unit.presets}
    
    var params: [String: Float] {unit.params}
}
