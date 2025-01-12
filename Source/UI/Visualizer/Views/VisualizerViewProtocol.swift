//
//  VisualizerViewProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    func setUp(with fft: FFT)
    
    func update(with fft: FFT)
    
    func setColors(startColor: NSColor, endColor: NSColor)
    
    func reset()
}

class AuralSCNView: SCNView {
    
    override var mouseDownCanMoveWindow: Bool {true}
    
    override func draw(_ dirtyRect: NSRect) {
        
        if self.scene == nil {
            dirtyRect.fill(withColor: .black)
            
        } else {
            super.draw(dirtyRect)
        }
    }
}
