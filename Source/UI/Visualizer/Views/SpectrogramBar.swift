//
//  SpectrogramBar.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import SpriteKit

class SpectrogramBar: SKSpriteNode {
    
    static var startColor: NSColor = .blue
    static var endColor: NSColor = .red
    
    static var barWidth: CGFloat = barWidth_10Band
    static let barWidth_10Band: CGFloat = 30
    static let barWidth_31Band: CGFloat = 13
    
    static let minHeight: CGFloat = 0.01
    
    static var numberOfBands: Int = 10 {
        
        didSet {
            
            gradientImage = numberOfBands == 10 ? gradientImage_10Band : gradientImage_31Band
            barWidth = numberOfBands == 10 ? barWidth_10Band : barWidth_31Band
        }
    }
    
    private static var gradientImage_10Band: NSImage = NSImage(named: "Sp-Gradient-10Band")!
    private static var gradientImage_31Band: NSImage = NSImage(named: "Sp-Gradient-31Band")!
    
    private static var gradientImage: NSImage = gradientImage_10Band {
        
        didSet {
            gradientTexture = SKTexture(image: gradientImage)
        }
    }
    
    private static var gradientTexture = SKTexture(image: gradientImage)
    
    var magnitude: CGFloat {
        
        didSet {
            
            let partialTexture = SKTexture(rect: NSRect(x: 0, y: 0, width: 1, height: max(Self.minHeight, magnitude)),
                                           in: Self.gradientTexture)
            let textureSize = partialTexture.size()
            
            run(SKAction.setTexture(partialTexture))
            run(SKAction.resize(toWidth: textureSize.width, height: textureSize.height, duration: 0.05))
        }
    }
    
    init(position: NSPoint, magnitude: CGFloat = 0) {
        
        self.magnitude = magnitude
        
        super.init(texture: Self.gradientTexture, color: Self.startColor, size: Self.gradientImage.size)
        
        self.yScale = 1

        self.anchorPoint = NSPoint.zero
        self.position = position
        
        self.blendMode = .replace
        
        let partialTexture = SKTexture(rect: NSRect(x: 0, y: 0, width: 1, height: max(Self.minHeight, magnitude)), in: Self.gradientTexture)
        run(SKAction.setTexture(partialTexture, resize: true))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func setColors(startColor: NSColor, endColor: NSColor) {
        
        Self.startColor = startColor
        Self.endColor = endColor
        
        // Compute a new gradient image
        gradientImage_10Band = NSImage(gradientColors: [startColor, endColor], imageSize: gradientImage_10Band.size)
        gradientImage_31Band = NSImage(gradientColors: [startColor, endColor], imageSize: gradientImage_31Band.size)
        
        gradientImage = numberOfBands == 10 ? gradientImage_10Band : gradientImage_31Band
        gradientTexture = SKTexture(image: gradientImage)
    }
}
