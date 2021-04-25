import Cocoa

class VisualizerUIPersistentState: PersistentStateProtocol {
    
    let type: VisualizationType?
    let options: VisualizerOptionsPersistentState?
    
    init(type: VisualizationType?, options: VisualizerOptionsPersistentState?) {
        
        self.type = type
        self.options = options
    }
    
    required init?(_ map: NSDictionary) {
        
        self.type = map.enumValue(forKey: "type", ofType: VisualizationType.self)
        self.options = map.objectValue(forKey: "options", ofType: VisualizerOptionsPersistentState.self)
    }
}

class VisualizerOptionsPersistentState: PersistentStateProtocol {
    
    var lowAmplitudeColor: ColorPersistentState?
    var highAmplitudeColor: ColorPersistentState?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        if let lowAmpColorDict = map["lowAmplitudeColor"] as? NSDictionary {
            self.lowAmplitudeColor = ColorPersistentState.deserialize(lowAmpColorDict)
        }
        
        if let highAmpColorDict = map["highAmplitudeColor"] as? NSDictionary {
            self.highAmplitudeColor = ColorPersistentState.deserialize(highAmpColorDict)
        }
    }
}

extension VisualizerViewState {
    
    static func initialize(_ persistentState: VisualizerUIPersistentState?) {
        
        type = persistentState?.type ?? .spectrogram
        
        options = VisualizerViewOptions()
        
        options.setColors(lowAmplitudeColor: persistentState?.options?.lowAmplitudeColor?.toColor() ?? VisualizerViewStateDefaults.lowAmplitudeColor,
                          highAmplitudeColor: persistentState?.options?.highAmplitudeColor?.toColor() ?? VisualizerViewStateDefaults.highAmplitudeColor)
    }
    
    static var persistentState: VisualizerUIPersistentState {
        
        let visOptions = VisualizerOptionsPersistentState()
        visOptions.lowAmplitudeColor = ColorPersistentState.fromColor(options.lowAmplitudeColor)
        visOptions.highAmplitudeColor = ColorPersistentState.fromColor(options.highAmplitudeColor)
        
        return VisualizerUIPersistentState(type: type, options: visOptions)
    }
}
