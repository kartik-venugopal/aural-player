import Cocoa

class VisualizerUIState: PersistentState {
    
    var type: String?
    var options: VisualizerOptionsState?
    
    static func deserialize(_ map: NSDictionary) -> VisualizerUIState {
        
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

class VisualizerOptionsState: PersistentState {
    
    var lowAmplitudeColor: ColorState?
    var highAmplitudeColor: ColorState?
    
    static func deserialize(_ map: NSDictionary) -> VisualizerOptionsState {
        
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
    
    static func initialize(_ appState: VisualizerUIState) {
        
        if let vizTypeString = appState.type {
            type = VisualizationType(rawValue: vizTypeString) ?? .spectrogram
        } else {
            type = .spectrogram
        }
        
        options = VisualizerViewOptions()
        options.setColors(lowAmplitudeColor: appState.options?.lowAmplitudeColor?.toColor() ?? NSColor.blue,
                          highAmplitudeColor: appState.options?.highAmplitudeColor?.toColor() ?? NSColor.red)
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
