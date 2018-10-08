import Foundation

class MasterPresets {
    
    private static var presets: [String: MasterPreset] = [String: MasterPreset]()
    
    static func presetByName(_ name: String) -> MasterPreset? {
        return presets[name]
    }
    
    static func allPresets() -> [MasterPreset] {
        
        var allPresets = [MasterPreset]()
        allPresets.append(contentsOf: presets.values)
        
        return allPresets
    }
    
    static func loadPresets(_ userDefinedPresets: [MasterPreset]) {
        userDefinedPresets.forEach({presets[$0.name] = $0})
    }
    
    static var userDefinedPresets: [MasterPreset] {
        return presets.values.filter({$0.systemDefined == false})
    }
    
    static func countUserDefinedPresets() -> Int {
        return userDefinedPresets.count
    }
    
    static func deletePresets(_ presetNames: [String]) {
        
        presetNames.forEach({
            presets[$0] = nil
        })
    }
    
    static var systemDefinedPresets: [MasterPreset] {
        return []
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedPreset(_ name: String, _ eq: EQPreset, _ pitch: PitchPreset, _ time: TimePreset, _ reverb: ReverbPreset, _ delay: DelayPreset, _ filter: FilterPreset) {
        
        presets[name] = MasterPreset(name, eq, pitch, time, reverb, delay, filter, false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
    
    static func renamePreset(_ oldName: String, _ newName: String) {
        
        if let preset = presetByName(oldName) {
            
            presets.removeValue(forKey: oldName)
            preset.name = newName
            presets[newName] = preset
        }
    }
}

class MasterPreset {
    
    var name: String
    
    let eq: EQPreset
    let pitch: PitchPreset
    let time: TimePreset
    let reverb: ReverbPreset
    let delay: DelayPreset
    let filter: FilterPreset
    
    let systemDefined: Bool
    
    init(_ name: String, _ eq: EQPreset, _ pitch: PitchPreset, _ time: TimePreset, _ reverb: ReverbPreset, _ delay: DelayPreset, _ filter: FilterPreset, _ systemDefined: Bool) {
        
        self.name = name
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        self.systemDefined = systemDefined
    }
}
