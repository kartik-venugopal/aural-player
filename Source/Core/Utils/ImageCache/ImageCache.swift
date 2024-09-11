//
// ImageCache.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class ImageCache<K: Hashable> {
    
    private var md5: ConcurrentMap<K, MD5String> = .init()
    private var images: ConcurrentMap<MD5String, ImageCacheEntry> = .init()
    
    let baseDir: URL
    let downscaledSize: NSSize
    let persistOriginalImage: Bool
    
    private lazy var readOpQueue: OperationQueue = OperationQueue(opCount: System.numberOfActiveCores, qos: .userInitiated)
    private lazy var writeOpQueue: OperationQueue = OperationQueue(opCount: System.numberOfActiveCores, qos: .background)
    
    init(baseDir: URL, downscaledSize: NSSize, persistOriginalImage: Bool) {
        
        self.baseDir = baseDir
        self.downscaledSize = downscaledSize
        self.persistOriginalImage = persistOriginalImage
    }
    
    func initialize(fromPersistentState persistentState: [K: MD5String]?) {

        for (key, md5String) in persistentState ?? [:] {
            
            writeOpQueue.addOperation {
                
                let imagesDir = self.baseDir.appendingPathComponent(md5String, isDirectory: true)
                imagesDir.createDirectory()
            }
        }
        
        writeOpQueue.waitUntilAllOperationsAreFinished()
    }
    
    subscript(_ key: K) -> CoverArt? {
        
        get {
            
            guard let theMD5 = md5[key] else {return nil}
            return images[theMD5]?.coverArt
        }
        
        set {
            
            guard let coverArt = newValue else {
                
                md5[key] = nil
                return
            }
            
            if let newEntry = ImageCacheEntry(coverArt: coverArt) {
                images[newEntry.md5] = newEntry
            }
        }
    }
    
    func md5(forKey key: K) -> String? {
        md5[key]
    }
    
    func persist() {
        
        for (md5String, entry) in images.map {
            
            let coverArt = entry.coverArt
            
            writeOpQueue.addOperation {
                
                let imagesDir = self.baseDir.appendingPathComponent(entry.md5, isDirectory: true)
                imagesDir.createDirectory()
                
                if self.persistOriginalImage, let originalImage = coverArt.originalImage {
                    
                    do {
                        try originalImage.image.writeToFile(fileType: .png, file: imagesDir.appendingPathComponent("original.png", isDirectory: false))
                    } catch {}
                }
                
                if let downscaledImage = coverArt.downscaledImage {
                    
                    do {
                        try downscaledImage.image.writeToFile(fileType: .png, file: imagesDir.appendingPathComponent("downscaled.png", isDirectory: false))
                    } catch {}
                }
            }
        }
    }
    
    var persistentState: [K: MD5String] {
        md5.map
    }
}

struct ImageCacheEntry {
    
    let md5: String
    let coverArt: CoverArt
    
    init?(coverArt: CoverArt) {
        
        guard let imageData = coverArt.originalImage?.imageData else {return nil}
        
        self.md5 = imageData.md5String
        self.coverArt = coverArt
    }
}
