import AVFoundation

protocol FXUnitProtocol {
    
    var state: EffectsUnitState {get}
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func toggleState() -> EffectsUnitState
    
    func suppress()
    
    func unsuppress()
    
    var avNodes: [AVAudioNode] {get}
    
    associatedtype PresetType: EffectsUnitPreset
    associatedtype PresetsType: FXPresetsProtocol
    
    var presets: PresetsType {get}
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ presetName: String)
    
    func applyPreset(_ preset: PresetType)
    
    var settingsAsPreset: PresetType {get}
}

protocol MasterUnitProtocol: FXUnitProtocol {}

protocol EQUnitProtocol: FXUnitProtocol {
    
    var type: EQType {get set}
    
    var globalGain: Float {get set}
    
    var bands: [Float] {get set}
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    func setBand(_ index: Int, gain: Float)
    
    // Increases the equalizer bass band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseBass(_ increment: Float) -> [Float]
    
    // Decreases the equalizer bass band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseBass(_ decrement: Float) -> [Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseMids(_ increment: Float) -> [Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseMids(_ decrement: Float) -> [Float]
    
    // Increases the equalizer treble band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseTreble(_ increment: Float) -> [Float]
    
    // Decreases the equalizer treble band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseTreble(_ decrement: Float) -> [Float]
}

protocol PitchShiftUnitProtocol: FXUnitProtocol {
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    var pitch: Float {get set}
    
    // the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    var overlap: Float {get set}
}

protocol TimeUnitProtocol: FXUnitProtocol {
    
    // The playback rate, specified as a value between 1/32 and 32
    var rate: Float {get set}
    
    // The amount of overlap between segments of the input audio signal into the time effects unit, specified as a value between 3 and 32
    var overlap: Float {get set}
    
    // An option to alter the pitch of the sound, along with the rate
    var shiftPitch: Bool {get set}
    
    // Returns the pitch offset of the time audio effects unit. If the pitch shift option of the unit is enabled, this value will range between -2400 and +2400 cents. It will be 0 otherwise (i.e. pitch unaltered).
    var pitch: Float {get}
}

protocol ReverbUnitProtocol: FXUnitProtocol {
    
    var space: ReverbSpaces {get set}
    
    var amount: Float {get set}
}

protocol DelayUnitProtocol: FXUnitProtocol {
    
    var amount: Float {get set}
    
    var time: Double {get set}
    
    var feedback: Float {get set}
    
    var lowPassCutoff: Float {get set}
}

protocol FilterUnitProtocol: FXUnitProtocol {
    
    var bands: [FilterBand] {get set}
    
    func getBand(_ index: Int) -> FilterBand
    
    func addBand(_ band: FilterBand) -> Int
    
    func updateBand(_ index: Int, _ band: FilterBand)
    
    func removeBands(_ indexSet: IndexSet)
    
    func removeAllBands()
}

protocol HostedAudioUnitProtocol: FXUnitProtocol {
    
    var name: String {get}
    
    var componentType: OSType {get}
    var componentSubType: OSType {get}
    
    var params: [AUParameterAddress: Float] {get}
    
    var auAudioUnit: AUAudioUnit {get}
    
    var factoryPresets: [AudioUnitFactoryPreset] {get}
    
    func applyFactoryPreset(_ preset: AudioUnitFactoryPreset)
    
    func applyFactoryPreset(_ presetName: String)
}
