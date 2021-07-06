//
//  VisualizerViewState.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class VisualizerViewState {
    
    static var type: VisualizationType = .spectrogram
    static var options: VisualizerViewOptions = VisualizerViewOptions()
    
    static func initialize(_ persistentState: VisualizerUIPersistentState?) {
        
        type = persistentState?.type ?? .spectrogram
        
        options = VisualizerViewOptions()
        
        options.setColors(lowAmplitudeColor: persistentState?.options?.lowAmplitudeColor?.toColor() ?? VisualizerViewStateDefaults.lowAmplitudeColor,
                          highAmplitudeColor: persistentState?.options?.highAmplitudeColor?.toColor() ?? VisualizerViewStateDefaults.highAmplitudeColor)
    }
    
    static var persistentState: VisualizerUIPersistentState {
        
        let visOptions = VisualizerOptionsPersistentState(lowAmplitudeColor: ColorPersistentState(color: options.lowAmplitudeColor),
                                                          highAmplitudeColor: ColorPersistentState(color: options.highAmplitudeColor))
        
        return VisualizerUIPersistentState(type: type, options: visOptions)
    }
}

class VisualizerViewStateDefaults {
    
    static let type: VisualizationType = .spectrogram
    static let options: VisualizerViewOptions = VisualizerViewOptions()
    
    static let lowAmplitudeColor: NSColor = .blue
    static let highAmplitudeColor: NSColor = .red
}
