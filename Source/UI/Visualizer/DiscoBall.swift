import Foundation
import SceneKit

class DiscoBall: AuralSCNView, VisualizerViewProtocol {
    
    let type: VisualizationType = .discoBall
    
    var data: BassFFTData = BassFFTData()
    
    var camera: SCNCamera!
    var cameraNode: SCNNode!
    
    var ambientLightNode: SCNNode!
    var ambientLight: SCNLight!
    
    var discoLightNode: SCNNode!
    var discoLight: SCNLight!
    
    var discoLightNode2: SCNNode!
    var discoLight2: SCNLight!
    
    var discoLightNode3: SCNNode!
    var discoLight3: SCNLight!
    
    var ball: SCNSphere!
    var node: SCNNode!
    let nodePosition: SCNVector3 = SCNVector3(0, 2, 1)
    
    var floorNode: SCNNode!
    var floor: SCNFloor!
    
    let textureImage: NSImage = NSImage(named: "DiscoBall")!
    
    func presentView(with fft: FFT) {
        
        data.setUp(for: fft)
        
        if self.scene == nil {
            
            self.scene = SCNScene()
            scene?.background.contents = NSColor.black
            
            camera = SCNCamera()
            cameraNode = SCNNode()
            cameraNode.camera = camera

            cameraNode.position = SCNVector3(0, 5, 4.5)
            cameraNode.eulerAngles = SCNVector3Make(-(piOver180 * 45), 0, 0)

            scene!.rootNode.addChildNode(cameraNode)
            
            ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.color = NSColor.white

            ambientLightNode = SCNNode()
            ambientLightNode.light = ambientLight
            
            scene!.rootNode.addChildNode(ambientLightNode)
            
            // MARK: Disco lights ----------------------------------------------------------------------
            
            // Below ball
            //            discoLightNode.position = SCNVector3(-0.1, 5, -2)
            
            discoLight = SCNLight()
            discoLight.type = .omni
            discoLight.color = startColor
            discoLight.intensity = 1000
            
            discoLightNode = SCNNode()
            discoLightNode.light = discoLight
            discoLightNode.position = SCNVector3(-19.5, 5, -15)
            
            scene!.rootNode.addChildNode(discoLightNode)
            
            discoLight2 = SCNLight()
            discoLight2.type = .omni
            discoLight2.color = startColor
            discoLight2.intensity = 1000

            discoLightNode2 = SCNNode()
            discoLightNode2.light = discoLight2
            discoLightNode2.position = SCNVector3(19.5, 5, -15)

            scene!.rootNode.addChildNode(discoLightNode2)
            
            discoLight3 = SCNLight()
            discoLight3.type = .omni
            discoLight3.color = startColor
            discoLight3.intensity = 1000

            discoLightNode3 = SCNNode()
            discoLightNode3.light = discoLight3
            discoLightNode3.position = SCNVector3(-0.1, 5, 2.5)

            scene!.rootNode.addChildNode(discoLightNode3)
            
            ball = SCNSphere(radius: 1)
            node = SCNNode(geometry: ball)
            
            node.position = nodePosition
            ball.firstMaterial?.diffuse.contents = textureImage.tinting(startColor)
            ball.firstMaterial?.diffuse.wrapS = .clamp
            ball.firstMaterial?.diffuse.wrapT = .clamp
            
            scene!.rootNode.addChildNode(node)
            
            floor = SCNFloor()
            floor.firstMaterial?.diffuse.contents = NSColor.black
            floor.firstMaterial?.lightingModel = .physicallyBased

            floorNode = SCNNode(geometry: floor)
            scene!.rootNode.addChildNode(floorNode)
            
            antialiasingMode = .multisampling4X
            isJitteringEnabled = true
            allowsCameraControl = false
            autoenablesDefaultLighting = false
            showsStatistics = false
            
            for level in 0...10 {
                textureCache.append(textureImage.tinting(startColor.interpolate(endColor, CGFloat(level) * 0.1)))
            }
            
        } else {
            updateTextureCache()
        }
        
        isPlaying = true
//        show()
    }
    
    func dismissView() {
        
        isPlaying = false
//        hide()
    }
    
    func updateTextureCache() {
        
        for level in 0...10 {
            textureCache[level] = textureImage.tinting(startColor.interpolate(endColor, CGFloat(level) * 0.1))
        }
    }
    
    var startColor: NSColor = .blue
    var endColor: NSColor = .red
    
    let animationDuration: TimeInterval = 0.05
    
    let maxRadiusIncreaseFactor: CGFloat = 0.25
    
    let minMagnitudeForRotation: CGFloat = 0.3
    var rotationDegrees: CGFloat = 0
    let maxRotationDegrees: CGFloat = 2.5
    
    // 11 images (11 levels of interpolation)
    var textureCache: [NSImage] = []
    
    func update(with fft: FFT) {
        
        if ball == nil {return}
        
        data.update(with: fft)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        
        let magnitude = CGFloat(data.peakBassMagnitude)
        
        ball.radius = 1 + (magnitude * maxRadiusIncreaseFactor)
        node.position = nodePosition
        
        let interpolationLevel: Int = min(Int(round(magnitude * 10.0)), 10)
        ball.firstMaterial?.diffuse.contents = textureCache[interpolationLevel]
        
        let discoLightColor = startColor.interpolate(endColor, magnitude)
        
        if magnitude > 0.7 {
            
            discoLight.color = discoLightColor
            discoLight2.color = discoLightColor
            
            discoLight.intensity = 1000
            discoLight2.intensity = 1000
            
        } else {
            
            discoLight2.intensity = 0
            discoLight.intensity = 0
        }
        
        discoLight3.color = discoLightColor
        
        if magnitude >= minMagnitudeForRotation {
            
            rotationDegrees += magnitude * maxRotationDegrees
            node.rotation = SCNVector4Make(0, 1, 0, rotationDegrees * piOver180)
        }
        
        SCNTransaction.commit()
    }
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        
        self.startColor = startColor
        self.endColor = endColor
        
        if self.isShown {
            updateTextureCache()
        }
    }
}
