//
//  VisualizerUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class VisualizerUIState {
    
    var type: VisualizationType = .spectrogram
    var options: VisualizerViewOptions = VisualizerViewOptions()
    
    init(persistentState: VisualizerUIPersistentState?) {
        
        type = persistentState?.type ?? .spectrogram
        
        options = VisualizerViewOptions()
        
        options.setColors(lowAmplitudeColor: persistentState?.options?.lowAmplitudeColor?.toColor() ?? VisualizerUIDefaults.lowAmplitudeColor,
                          highAmplitudeColor: persistentState?.options?.highAmplitudeColor?.toColor() ?? VisualizerUIDefaults.highAmplitudeColor)
    }
    
    var persistentState: VisualizerUIPersistentState {
        
        let visOptions = VisualizerOptionsPersistentState(lowAmplitudeColor: ColorPersistentState(color: options.lowAmplitudeColor),
                                                          highAmplitudeColor: ColorPersistentState(color: options.highAmplitudeColor))
        
        return VisualizerUIPersistentState(type: type, options: visOptions)
    }
}

class VisualizerUIDefaults {
    
    static let type: VisualizationType = .spectrogram
    static let options: VisualizerViewOptions = VisualizerViewOptions()
    
    static let lowAmplitudeColor: NSColor = .blue
    static let highAmplitudeColor: NSColor = .red
}
