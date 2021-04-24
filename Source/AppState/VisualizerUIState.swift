import Cocoa

class VisualizerUIState: PersistentStateProtocol {
    
    let type: VisualizationType?
    let options: VisualizerOptionsState?
    
    init(type: VisualizationType?, options: VisualizerOptionsState?) {
        
        self.type = type
        self.options = options
    }
    
    required init?(_ map: NSDictionary) {
        
        self.type = map.enumValue(forKey: "type", ofType: VisualizationType.self)
        self.options = map.objectValue(forKey: "options", ofType: VisualizerOptionsState.self)
    }
}

class VisualizerOptionsState: PersistentStateProtocol {
    
    var lowAmplitudeColor: ColorState?
    var highAmplitudeColor: ColorState?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        if let lowAmpColorDict = map["lowAmplitudeColor"] as? NSDictionary {
            self.lowAmplitudeColor = ColorState.deserialize(lowAmpColorDict)
        }
        
        if let highAmpColorDict = map["highAmplitudeColor"] as? NSDictionary {
            self.highAmplitudeColor = ColorState.deserialize(highAmpColorDict)
        }
    }
}

extension VisualizerViewState {
    
    static func initialize(_ persistentState: VisualizerUIState) {
        
        type = persistentState.type ?? .spectrogram
        
        options = VisualizerViewOptions()
        
        options.setColors(lowAmplitudeColor: persistentState.options?.lowAmplitudeColor?.toColor() ?? VisualizerViewStateDefaults.lowAmplitudeColor,
                          highAmplitudeColor: persistentState.options?.highAmplitudeColor?.toColor() ?? VisualizerViewStateDefaults.highAmplitudeColor)
    }
    
    static var persistentState: VisualizerUIState {
        
        let visOptions = VisualizerOptionsState()
        visOptions.lowAmplitudeColor = ColorState.fromColor(options.lowAmplitudeColor)
        visOptions.highAmplitudeColor = ColorState.fromColor(options.highAmplitudeColor)
        
        return VisualizerUIState(type: type, options: visOptions)
    }
}
