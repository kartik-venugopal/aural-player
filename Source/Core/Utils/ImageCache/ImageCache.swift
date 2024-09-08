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
    
    private var md5: ConcurrentMap<K, String> = .init()
    private var images: ConcurrentMap<String, ImageCacheEntry> = .init()
    
    var downscaledSize: NSSize = .init(width: 200, height: 200)
    
    
    
//    subscript(_ key: K) -> NSImage? {
//        
//        get {
//            
//            lock.produceValueAfterWait {
//                map[key]
//            }
//        }
//        
//        set {
//            
//            lock.executeAfterWait {
//                
//                if let theValue = newValue {
//                    
//                    // newValue is non-nil
//                    map[key] = theValue
//                    
//                } else {
//                    
//                    // newValue is nil, implying that any existing value should be removed for this key.
//                    _ = map.removeValue(forKey: key)
//                }
//            }
//        }
//    }
}

struct ImageCacheEntry {
    
    let md5: String
    let data: Data
    let image: NSImage
    
    init?(data: Data) {
        
        self.md5 = data.md5String
        self.data = data
        
        guard let image = NSImage(data: data) else {return nil}
        self.image = image
    }
}
