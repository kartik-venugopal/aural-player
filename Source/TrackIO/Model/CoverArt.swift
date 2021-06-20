import Cocoa

class CoverArt {
    
    var image: NSImage
    var metadata: ImageMetadata?
    
    init?(imageFile: URL) {
        
        guard let image = NSImage(contentsOfFile: imageFile.path) else {return nil}
        self.image = image
        
        do {

            // Read the image file for image metadata.
            let imgData: Data = try Data(contentsOf: imageFile)
            self.metadata = ParserUtils.getImageMetadata(imgData as NSData)
            
        } catch {
            NSLog("Warning - Unable to read data from the image file: \(imageFile.path)")
        }
    }
    
    init?(imageData: Data) {
        
        guard let image = NSImage(data: imageData) else {return nil}
        
        self.image = image
        self.metadata = ParserUtils.getImageMetadata(imageData as NSData)
    }
}

class ImageMetadata {
    
    // e.g. JPEG/PNG
    var type: String? = nil
    
    // e.g. 1680x1050
    var dimensions: NSSize? = nil
    
    // e.g. 72x72 DPI
    var resolution: NSSize? = nil
    
    // e.g. RGB
    var colorSpace: String? = nil
    
    // e.g. "sRGB IEC61966-2.1"
    var colorProfile: String? = nil
    
    // e.g. 8 bit
    var bitDepth: Int? = nil

    // True for transparent images like PNGs
    var hasAlpha: Bool? = nil
}
