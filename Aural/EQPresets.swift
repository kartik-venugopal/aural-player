import Foundation

class EQPresets {
    
    private static var presets: [String: EQPreset] = {
        
        var map = [String: EQPreset]()
        SystemDefinedEQPresets.allValues.forEach({
            map[$0.rawValue] = EQPreset($0.rawValue, $0.state, $0.bands, $0.globalGain, true)
        })
        
        return map
    }()
    
    static var userDefinedPresets: [EQPreset] {
        return presets.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedPresets: [EQPreset] {
        return presets.values.filter({$0.systemDefined == true})
    }
    
    static var defaultPreset: EQPreset {
        return presetByName(SystemDefinedEQPresets.flat.rawValue)
    }
    
    static func presetByName(_ name: String) -> EQPreset {
        return presets[name] ?? defaultPreset
    }
    
    static func countUserDefinedPresets() -> Int {
        return userDefinedPresets.count
    }
    
    static func deletePresets(_ presetNames: [String]) {
        
        presetNames.forEach({
            presets[$0] = nil
        })
    }
    
    static func renamePreset(_ oldName: String, _ newName: String) {
        
        if presetWithNameExists(oldName) {
            
            let preset = presetByName(oldName)
            
            presets.removeValue(forKey: oldName)
            preset.name = newName
            presets[newName] = preset
        }
    }
    
    static func loadUserDefinedPresets(_ userDefinedPresets: [EQPreset]) {
        userDefinedPresets.forEach({presets[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedPreset(_ name: String, _ state: EffectsUnitState, _ bands: [Int: Float], _ globalGain: Float) {
        presets[name] = EQPreset(name, state, bands, globalGain, false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
}

class EQPreset: EffectsUnitPreset {
    
    let bands: [Int: Float]
    let globalGain: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ bands: [Int: Float], _ globalGain: Float, _ systemDefined: Bool) {
        
        self.bands = bands
        self.globalGain = globalGain
        super.init(name, state, systemDefined)
    }
}

/*
    An enumeration of Equalizer presets the user can choose from
 */
fileprivate enum SystemDefinedEQPresets: String {
    
    case flat = "Flat" // default
    case highBassAndTreble = "High bass and treble"
    
    case dance = "Dance"
    case electronic = "Electronic"
    case hipHop = "Hip Hop"
    case jazz = "Jazz"
    case latin = "Latin"
    case lounge = "Lounge"
    case piano = "Piano"
    case pop = "Pop"
    case rAndB = "R&B"
    case rock = "Rock"
    
    case soft = "Soft"
    case karaoke = "Karaoke"
    case vocal = "Vocal"
    
    static var allValues: [SystemDefinedEQPresets] = [.flat, .highBassAndTreble, .dance, .electronic, .hipHop, .jazz, .latin, .lounge, .piano, .pop, .rAndB, .rock, .soft, .karaoke, .vocal]
    
    // Converts a user-friendly display name to an instance of EQPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedEQPresets {
        return SystemDefinedEQPresets(rawValue: displayName) ?? .flat
    }
    
    // Returns the frequency->gain mappings for each of the frequency bands, for this preset
    var bands: [Int: Float] {
        
        switch self {
            
        case .flat: return EQPresetsBands.flatBands
        case .highBassAndTreble: return EQPresetsBands.highBassAndTrebleBands
            
        case .dance: return EQPresetsBands.danceBands
        case .electronic: return EQPresetsBands.electronicBands
        case .hipHop: return EQPresetsBands.hipHopBands
        case .jazz: return EQPresetsBands.jazzBands
        case .latin: return EQPresetsBands.latinBands
        case .lounge: return EQPresetsBands.loungeBands
        case .piano: return EQPresetsBands.pianoBands
        case .pop: return EQPresetsBands.popBands
        case .rAndB: return EQPresetsBands.rAndBBands
        case .rock: return EQPresetsBands.rockBands
            
        case .soft: return EQPresetsBands.softBands
        case .vocal: return EQPresetsBands.vocalBands
        case .karaoke: return EQPresetsBands.karaokeBands
            
        }
    }
    
    var globalGain: Float {
        return 0
    }
    
    var state: EffectsUnitState {
        return .active
    }
}

// Container for specific frequency->gain mappings for different EQ presets
fileprivate struct EQPresetsBands {
    
    static let flatBands: [Int: Float] = {
        
        return EQBands([0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0]).bands
    }()
    
    static let highBassAndTrebleBands: [Int: Float] = {
        
        return EQBands([15, 12.5, 10,
                        0, 0, 0, 0,
                        10, 12.5, 15]).bands
    }()
    
    static let danceBands: [Int: Float] = {
        
        return EQBands([0, 7, 4,
                        0, -1, -2, -4,
                        0, 4, 5]).bands
    }()
    
    static let electronicBands: [Int: Float] = {
        
        return EQBands([7, 6.5, 0,
                        -2, -5, 0, 0,
                        0, 6.5, 7]).bands
    }()
    
    static let hipHopBands: [Int: Float] = {
        
        return EQBands([7, 7, 0,
                        0, -3, -3, -2,
                        1, 1, 7]).bands
    }()
    
    static let jazzBands: [Int: Float] = {
        
        return EQBands([0, 3, 0,
                        0, -3, -3, 0,
                        0, 3, 5]).bands
    }()
    
    static let latinBands: [Int: Float] = {
        
        return EQBands([8, 5, 0,
                        0, -4, -4, -4,
                        0, 6, 8]).bands
    }()
    
    static let loungeBands: [Int: Float] = {
        
        return EQBands([-5, -2, 0,
                        2, 4, 3, 0,
                        0, 3, 0]).bands
    }()
    
    static let pianoBands: [Int: Float] = {
        
        return EQBands([1, -1, -3,
                        0, 1, -1, 2,
                        3, 1, 2]).bands
    }()
    
    static let popBands: [Int: Float] = {
        
        return EQBands([-2, -1.5, 0,
                        3, 7, 7, 3.5,
                        0, -2, -3]).bands
    }()
    
    static let rAndBBands: [Int: Float] = {
        
        return EQBands([0, 7, 4,
                        -3, -5, -4.5, -2,
                        -1.5, 0, 1.5]).bands
    }()
    
    static let rockBands: [Int: Float] = {
        
        return EQBands([5, 3, 1.5,
                        0, -5, -6, -2.5,
                        0, 2.5, 4]).bands
    }()
    
    static let softBands: [Int: Float] = {
        
        return EQBands([0, 1, 2,
                        6, 8, 10, 12,
                        12, 13, 14]).bands
    }()
    
    static let karaokeBands: [Int: Float] = {
        
        return EQBands([8, 6, 4,
                        -20, -20, -20, -20,
                        4, 6, 8]).bands
    }()
    
    static let vocalBands: [Int: Float] = {
        
        return EQBands([-20, -20, -20,
                        12, 14, 14, 12,
                        -20, -20, -20]).bands
    }()
}

struct EQBands {
    
    var bands = [Int: Float]()
    
    init(_ gains: [Float]) {
        
        for i in 0..<10 {
            bands[i] = gains[i]
        }
    }
}
