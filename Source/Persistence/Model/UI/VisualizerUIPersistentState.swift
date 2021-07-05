//
//  VisualizerUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

struct VisualizerUIPersistentState: Codable {
    
    let type: VisualizationType?
    let options: VisualizerOptionsPersistentState?
}

struct VisualizerOptionsPersistentState: Codable {
    
    let lowAmplitudeColor: ColorPersistentState?
    let highAmplitudeColor: ColorPersistentState?
}

extension VisualizerViewState {
    
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
