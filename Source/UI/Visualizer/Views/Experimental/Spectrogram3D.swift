//
//  Spectrogram3D.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
//import SceneKit

//class Spectrogram3D: SCNView, VisualizerViewProtocol {
//
//    var data: FrequencyData!
//    let magnitudeRange: ClosedRange<CGFloat> = 0...1
//
//    lazy var xMargin: CGFloat = xMargin_10Band
//    let xMargin_10Band: CGFloat = 0.6
//    let xMargin_31Band: CGFloat = 0.38
//
//    var bars: [Spectrogram3DBar] = []
//    var spacing: CGFloat {barThickness}
//
//    var numberOfBands: Int = 10 {
//
//        didSet {
//
////            scene?.isPaused = true
////
////            bars.forEach {$0.node.removeFromParentNode()}
////            bars.removeAll()
////
////            gradientImage = numberOfBands == 10 ? gradientImage_10Band : gradientImage_31Band
////            barThickness = numberOfBands == 10 ? barThickness_10Band : barThickness_31Band
////            xMargin = numberOfBands == 10 ? xMargin_10Band : xMargin_31Band
////
////            let magnitude: CGFloat = 0.05
////
////            for i in 0..<numberOfBands {
////
////                let bar = Spectrogram3DBar(position: SCNVector3(xMargin + CGFloat(i) * (barThickness + spacing), 0, 0),
////                                         magnitude: magnitude,
////                                         thickness: barThickness,
////                                         gradientImage: gradientImage)
////
////                bars.append(bar)
////                scene!.rootNode.addChildNode(bar.node)
////            }
////
////            scene?.isPaused = false
//        }
//    }
//
//    var camera: SCNCamera!
//    var cameraNode: SCNNode!
//
//    var floorNode: SCNNode!
//    var floor: SCNFloor!
//
//    let piOver180: CGFloat = CGFloat.pi / 180
//
//    lazy var barThickness: CGFloat = barThickness_10Band
//    let barThickness_10Band: CGFloat = 0.25
//    let barThickness_31Band: CGFloat = 0.1
//
//    lazy var gradientImage: NSImage = gradientImage_10Band
//    var gradientImage_10Band: NSImage = NSImage(named: "Sp3D-Gradient-10Band")!
//    var gradientImage_31Band: NSImage = NSImage(named: "Sp-Gradient-31Band")!
//
//    private var startColor: NSColor = .blue
//    private var endColor: NSColor = .red
//
//    func presentView() {
//
//        if self.scene == nil {
//
//            scene = SCNScene()
//            scene?.background.contents = NSColor.black
//
//            camera = SCNCamera()
//            cameraNode = SCNNode()
//            cameraNode.camera = camera
//
//            cameraNode.position = SCNVector3(3, 2, 4.5)
//            cameraNode.eulerAngles = SCNVector3Make(-(CGFloat.pi / 45), (CGFloat.pi / 180), 0)
//
//            scene!.rootNode.addChildNode(cameraNode)
//
//            // MARK: Bar ---------------------------------------
//
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0
//
//            self.numberOfBands = 10
//
//            SCNTransaction.commit()
//
//            // MARK: Floor ---------------------------------------
//
//            floor = SCNFloor()
//            floor.firstMaterial?.diffuse.contents = NSColor.black
//            floor.firstMaterial?.lightingModel = .physicallyBased
//
//            floorNode = SCNNode(geometry: floor)
//            scene!.rootNode.addChildNode(floorNode)
//
//            // MARK: Scene settings ---------------------------------------
//
//            antialiasingMode = .multisampling4X
//            isJitteringEnabled = true
//            allowsCameraControl = true
//            autoenablesDefaultLighting = false
//            showsStatistics = false
//        }
//
//        scene?.isPaused = false
//        show()
//    }
//    
//    func dismissView() {
//        scene?.isPaused = true
//        hide()
//    }
//
//    func update() {
//
////        SCNTransaction.begin()
////        SCNTransaction.animationDuration = 0
////
////        for i in 0..<numberOfBands {
////            bars[i].magnitude = CGFloat(FrequencyData.bands[i].maxVal).clamp(to: magnitudeRange)
////        }
////
////        SCNTransaction.commit()
//    }
//
//    func setColors(startColor: NSColor, endColor: NSColor) {
//
////        self.startColor = startColor
////        self.endColor = endColor
////
////        Spectrogram3DBar.startColor = startColor
////        Spectrogram3DBar.endColor = endColor
////
////        gradientImage_10Band = NSImage(gradientColors: [startColor, endColor], imageSize: gradientImage_10Band.size)
////        gradientImage_31Band = NSImage(gradientColors: [startColor, endColor], imageSize: gradientImage_31Band.size)
////
////        gradientImage = numberOfBands == 10 ? gradientImage_10Band : gradientImage_31Band
////        bars.forEach {$0.gradientImage = gradientImage}
////        bars.forEach {$0.colorsUpdated()}
//    }
//}
