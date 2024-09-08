//
//  CoverArt.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit
import CoreGraphics

///
/// Encapsulates album art and metadata about the image.
///
struct CoverArt {
    
    let image: NSImage
    let imageData: Data
    let metadata: ImageMetadata?
    
    init?(imageFile: URL, metadata: ImageMetadata? = nil) {
        
        do {

            // Read the image file for image metadata.
            let imgData: Data = try Data(contentsOf: imageFile)
            guard let image = NSImage(data: imgData) else {return nil}
            
            self.imageData = imgData
            self.image = image
            self.metadata = metadata ?? ParserUtils.getImageMetadata(imgData)
            
        } catch {
            
            NSLog("Warning - Unable to read data from the image file: \(imageFile.path)")
            return nil
        }
    }
    
    init?(imageData: Data, metadata: ImageMetadata? = nil) {
        
        guard let image = NSImage(data: imageData) else {return nil}
        
        self.image = image
        self.metadata = metadata ?? ParserUtils.getImageMetadata(imageData)
        self.imageData = imageData
    }
}

///
/// Metadata about an image (cover art).
///
struct ImageMetadata: Codable {
    
    // e.g. JPEG/PNG
    var type: String? = nil
    
    // e.g. 1680x1050
    var dimensions: CGSize? = nil
    
    // e.g. 72x72 DPI
    var resolution: CGSize? = nil
    
    // e.g. RGB
    var colorSpace: String? = nil
    
    // e.g. "sRGB IEC61966-2.1"
    var colorProfile: String? = nil
    
    // e.g. 8 bit
    var bitDepth: Int? = nil

    // True for transparent images like PNGs
    var hasAlpha: Bool? = nil
}
