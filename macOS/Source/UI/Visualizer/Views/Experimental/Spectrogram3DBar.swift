//
//  Spectrogram3DBar.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
//import SceneKit

//class Spectrogram3DBar {
//    
//    static var startColor: NSColor = .blue
//    static var endColor: NSColor = .red
//    
//    static let bottomMaterial: SCNMaterial = {
//
//        let material = SCNMaterial()
//        material.diffuse.contents = NSColor.black
//        return material
//    }()
//    
//    let box: SCNBox
//    let node: SCNNode
//    
//    private let sideGradientMaterial = SCNMaterial()
//    private let topMaterial = SCNMaterial()
//    
//    private static let minHeight: CGFloat = 0.05
//    private static let maxHeight: CGFloat = 4
//    
//    var gradientImage: NSImage {
//        
//        didSet {
//            sideGradientMaterial.diffuse.contents = gradientImage
//        }
//    }
//    
//    var magnitude: CGFloat {
//        
//        didSet {
//            
//            box.height = max(Self.minHeight, min(Self.maxHeight, magnitude * Self.maxHeight))
//            node.pivot = SCNMatrix4MakeTranslation(0, -(box.height / 2), 0)
//            
//            let scale = SCNMatrix4MakeScale(1, box.height / Self.maxHeight, 1)
//            sideGradientMaterial.diffuse.contentsTransform = SCNMatrix4Translate(scale, 0, (Self.maxHeight - box.height) / Self.maxHeight, 0)
//            
//            topMaterial.diffuse.contents = Self.startColor.interpolate(Self.endColor, magnitude)
//        }
//    }
//    
//    init(position: SCNVector3, magnitude: CGFloat = 0, thickness: CGFloat, gradientImage: NSImage) {
//        
//        self.magnitude = magnitude
//        let height = min(Self.maxHeight, magnitude * Self.maxHeight)
//        self.box = SCNBox(width: thickness, height: height, length: thickness, chamferRadius: 0)
//        
//        self.node = SCNNode(geometry: box)
//        self.node.position = position
//        self.node.pivot = SCNMatrix4MakeTranslation(0, -(height / 2), 0)
//        
//        self.gradientImage = gradientImage
//        self.sideGradientMaterial.diffuse.contents = self.gradientImage
//        
//        self.box.materials = [sideGradientMaterial, sideGradientMaterial, sideGradientMaterial, sideGradientMaterial, topMaterial, Self.bottomMaterial]
////        box.firstMaterial?.diffuse.contents = Self.startColor.interpolate(Self.endColor, magnitude)
//        
//        let scale = SCNMatrix4MakeScale(1, box.height / Self.maxHeight, 1)
//        sideGradientMaterial.diffuse.contentsTransform = SCNMatrix4Translate(scale, 0, (Self.maxHeight - box.height) / Self.maxHeight, 0)
//        
//        box.materials[4] = topMaterial
//        topMaterial.diffuse.contents = Self.startColor.interpolate(Self.endColor, magnitude)
//    }
//    
//    func colorsUpdated() {
//        box.firstMaterial?.diffuse.contents = Self.startColor.interpolate(Self.endColor, magnitude)
//    }
//}
