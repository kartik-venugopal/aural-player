import Cocoa
import SceneKit
import SpriteKit

extension SKTexture {
    
    convenience init(size: CGSize, color1: CIColor, color2: CIColor) {
        
        let coreImageContext = CIContext(options: nil)
        
        let gradientFilter = CIFilter(name: "CILinearGradient")!
        gradientFilter.setDefaults()
        
        let startVector: CIVector = CIVector(x: size.width / 2, y: 0)
        let endVector: CIVector = CIVector(x: size.width / 2, y: size.height)
        
        gradientFilter.setValue(startVector, forKey: "inputPoint0")
        gradientFilter.setValue(endVector, forKey: "inputPoint1")
        gradientFilter.setValue(color1, forKey: "inputColor0")
        gradientFilter.setValue(color2, forKey: "inputColor1")
        
        let cgimg = coreImageContext.createCGImage(gradientFilter.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))!
        self.init(cgImage:cgimg)
    }
}

extension NSImage {
    
    
}

let piOver180: CGFloat = CGFloat.pi / 180
