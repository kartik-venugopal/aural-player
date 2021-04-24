import Cocoa

class VisualizerUIState: PersistentStateProtocol {
    
    var type: String?
    var options: VisualizerOptionsState?
    
    required init?(_ map: NSDictionary) -> VisualizerUIState {
        
        let state = VisualizerUIState()
        
        if let type = map["type"] as? String {
            state.type = type
        }
        
        if let optionsDict = map["options"] as? NSDictionary {
            state.options = VisualizerOptionsState.deserialize(optionsDict)
        }
        
        return state
    }
}

class VisualizerOptionsState: PersistentStateProtocol {
    
    var lowAmplitudeColor: ColorState?
    var highAmplitudeColor: ColorState?
    
    required init?(_ map: NSDictionary) -> VisualizerOptionsState {
        
        let state = VisualizerOptionsState()
        
        if let colorDict = map["lowAmplitudeColor"] as? NSDictionary {
            state.lowAmplitudeColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["highAmplitudeColor"] as? NSDictionary {
            state.highAmplitudeColor = ColorState.deserialize(colorDict)
        }
        
        return state
    }
}

extension VisualizerViewState {
    
    static func initialize(_ persistentState: VisualizerUIState) {
        
        if let vizTypeString = persistentState.type {
            type = VisualizationType(rawValue: vizTypeString) ?? .spectrogram
        } else {
            type = .spectrogram
        }
        
        options = VisualizerViewOptions()
        options.setColors(lowAmplitudeColor: persistentState.options?.lowAmplitudeColor?.toColor() ?? NSColor.blue,
                          highAmplitudeColor: persistentState.options?.highAmplitudeColor?.toColor() ?? NSColor.red)
    }
    
    static var persistentState: VisualizerUIState {
        
        let state = VisualizerUIState()
        
        state.type = type.rawValue
        state.options = VisualizerOptionsState()
        state.options?.lowAmplitudeColor = ColorState.fromColor(options.lowAmplitudeColor)
        state.options?.highAmplitudeColor = ColorState.fromColor(options.highAmplitudeColor)
        
        return state
    }
}
