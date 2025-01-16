//
// ImageCache.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

typealias ImageCacheKeyFunction = (Track, CoverArt) -> String?

class ImageCache {
    
    private var imageKeys: ConcurrentMap<URL, String> = .init()
    private var images: ConcurrentMap<String, ImageCacheEntry> = .init()
    
    var keyFunction: ImageCacheKeyFunction = {_,_ in ""}
    
    let baseDir: URL
    let downscaledSize: NSSize
    let persistOriginalImage: Bool
    
    var keysCount: Int {
        imageKeys.count
    }
    
    var imageCount: Int {
        images.count
    }
    
    private lazy var writeOpQueue: OperationQueue = OperationQueue(opCount: System.numberOfActiveCores, qos: .background)
    
    init(baseDir: URL, downscaledSize: NSSize, persistOriginalImage: Bool) {
        
        self.baseDir = baseDir
        self.downscaledSize = downscaledSize
        self.persistOriginalImage = persistOriginalImage
        
        DispatchQueue.global(qos: .background).async {
            baseDir.createDirectory()
        }
    }
    
    func initialize(fromPersistentState persistentState: [URL: String], onQueue queue: OperationQueue) {

        for (file, key) in persistentState {
            
            queue.addOperation {
                
                var originalImage: NSImage?
                var downscaledImage: NSImage?
                
                let imagesDir = self.baseDir.appendingPathComponent(key, isDirectory: true)
                
                let origFile = imagesDir.appendingPathComponent("original.png", isDirectory: false)
                let downscaledFile = imagesDir.appendingPathComponent("downscaled.png", isDirectory: false)
                
                if origFile.exists {
                    originalImage = NSImage(contentsOf: origFile)
                }
                
                if downscaledFile.exists {
                    downscaledImage = NSImage(contentsOf: downscaledFile)
                }
                
                self.imageKeys[file] = key
                self.images[key] = .init(key: key, coverArt: CoverArt(source: .file, originalImage: originalImage, downscaledImage: downscaledImage))
            }
        }
    }
    
    func addToCache(coverArt: CoverArt, forTrack track: Track, persistNewEntry: Bool) {
        
        guard let key = keyFunction(track, coverArt) else {return}
        
        let newEntry = ImageCacheEntry(key: key, coverArt: coverArt)
            
        imageKeys[track.file] = key
        images[key] = newEntry
        
        if persistNewEntry {
            
            DispatchQueue.global(qos: .utility).async {
                self.persistEntry(newEntry)
            }
        }
    }
    
    subscript(_ file: URL) -> CoverArt? {
        
        guard let key = imageKeys[file] else {return nil}
        return images[key]?.coverArt
    }
    
    func persistAllEntries() {
        
        DispatchQueue.global(qos: .utility).async {
            
            for (_, entry) in self.images.map {
                
                if !entry.persisted {
                    self.persistEntry(entry)
                }
            }
        }
    }
    
    private func persistEntry(_ entry: ImageCacheEntry) {
        
        let coverArt = entry.coverArt
        
        writeOpQueue.addOperation {
            
            let imagesDir = self.baseDir.appendingPathComponent(entry.key, isDirectory: true)
            imagesDir.createDirectory()
            
            if self.persistOriginalImage, let originalImage = coverArt.originalImage {
                
                do {
                    
                    try originalImage.image.writeToFile(fileType: .png, file: imagesDir.appendingPathComponent("original.png", isDirectory: false))
                    entry.persisted = true
                    
                } catch {}
            }
            
            if let originalImage = coverArt.originalImage,
               let downscaledImage = originalImage.image.resized(to: self.downscaledSize) {
                
                coverArt.downscaledImage = .init(image: downscaledImage)
            }
            
            if let downscaledImage = coverArt.downscaledImage {
                
                do {
                    
                    try downscaledImage.image.writeToFile(fileType: .png, file: imagesDir.appendingPathComponent("downscaled.png", isDirectory: false))
                    entry.persisted = true
                    
                } catch {}
            }
        }
    }
    
    func clearCache() {
        
        imageKeys.removeAll()
        images.removeAll()
        
        DispatchQueue.global(qos: .background).async {
            self.baseDir.delete()
        }
    }
    
    var persistentState: [URL: String] {
        imageKeys.map
    }
}

class ImageCacheEntry {
    
    let key: String
    let coverArt: CoverArt
    
    fileprivate var persisted: Bool
    
    init(key: String, coverArt: CoverArt) {
        
        self.key = key
        self.coverArt = coverArt
        self.persisted = false
    }
}
