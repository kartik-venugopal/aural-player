import Cocoa
import SpriteKit
import SceneKit

protocol VisualizerViewProtocol {
    
    var type: VisualizationType {get}
    
//    var options: VisualizerViewOptions {get set}
    
    func presentView(with fft: FFT)
    
    func dismissView()
    
    func update(with fft: FFT)
    
    func setColors(startColor: NSColor, endColor: NSColor)
}

class AuralSKView: SKView {
    
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
