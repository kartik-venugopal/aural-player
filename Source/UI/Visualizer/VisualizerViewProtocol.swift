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

enum VisualizationType: String, CaseIterable {
    
    case spectrogram, supernova, discoBall
}

class VisualizerViewOptions {
    
    var lowAmplitudeColor: NSColor = VisualizerViewStateDefaults.lowAmplitudeColor
    var highAmplitudeColor: NSColor = VisualizerViewStateDefaults.highAmplitudeColor
    
    func setColors(lowAmplitudeColor: NSColor, highAmplitudeColor: NSColor) {
        
        self.lowAmplitudeColor = lowAmplitudeColor
        self.highAmplitudeColor = highAmplitudeColor
    }
}

class VisualizerViewState {
    
    static var type: VisualizationType = VisualizerViewStateDefaults.type
    static var options: VisualizerViewOptions = VisualizerViewStateDefaults.options
}

class VisualizerViewStateDefaults {
    
    static let type: VisualizationType = .spectrogram
    static let options: VisualizerViewOptions = VisualizerViewOptions()
    
    static let lowAmplitudeColor: NSColor = .blue
    static let highAmplitudeColor: NSColor = .red
}
