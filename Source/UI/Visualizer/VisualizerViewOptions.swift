//
//  VisualizerViewOptions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class VisualizerViewOptions {
    
    var lowAmplitudeColor: NSColor = .blue
    var highAmplitudeColor: NSColor = .red
    
    func setColors(lowAmplitudeColor: NSColor, highAmplitudeColor: NSColor) {
        
        self.lowAmplitudeColor = lowAmplitudeColor
        self.highAmplitudeColor = highAmplitudeColor
    }
}
