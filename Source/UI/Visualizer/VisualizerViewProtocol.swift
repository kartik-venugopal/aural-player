//
//  VisualizerViewProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import SpriteKit
import SceneKit

protocol VisualizerViewProtocol {
    
    var type: VisualizationType {get}
    
    func presentView(with fft: FFT)
    
    func dismissView()
    
    func update(with fft: FFT)
    
    func setColors(startColor: NSColor, endColor: NSColor)
}

class AuralSCNView: SCNView {
    
    override var mouseDownCanMoveWindow: Bool {true}
    
    override func draw(_ dirtyRect: NSRect) {
        
        if self.scene == nil {
            
            NSColor.black.setFill()
            dirtyRect.fill()
            
        } else {
            super.draw(dirtyRect)
        }
    }
}

enum VisualizationType: String, CaseIterable, Codable {
    
    case spectrogram, supernova, discoBall
}

class VisualizerViewOptions {
    
    var lowAmplitudeColor: NSColor = .blue
    var highAmplitudeColor: NSColor = .red
    
    func setColors(lowAmplitudeColor: NSColor, highAmplitudeColor: NSColor) {
        
        self.lowAmplitudeColor = lowAmplitudeColor
        self.highAmplitudeColor = highAmplitudeColor
    }
}

class VisualizerViewState {
    
    static var type: VisualizationType = .spectrogram
    static var options: VisualizerViewOptions = VisualizerViewOptions()
}

class VisualizerViewStateDefaults {
    
    static let type: VisualizationType = .spectrogram
    static let options: VisualizerViewOptions = VisualizerViewOptions()
    
    static let lowAmplitudeColor: NSColor = .blue
    static let highAmplitudeColor: NSColor = .red
}
