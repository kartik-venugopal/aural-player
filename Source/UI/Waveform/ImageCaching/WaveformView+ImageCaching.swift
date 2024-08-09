////
////  WaveformView+ImageCaching.swift
////  Periphony: Spatial Audio Player
////  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
////  Developed by Kartik Venugopal
////
//
import Foundation
//import CoreGraphics

fileprivate var encoder: JSONEncoder = {
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    return encoder
}()

fileprivate let decoder: JSONDecoder = JSONDecoder()

extension WaveformView {
    
    static let cacheBaseDirectory: URL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("/aural-waveform/waveformImageCache")
    
    static let cache: ConcurrentMap<URL, ConcurrentArray<WaveformCacheEntry>> = ConcurrentMap()
 
    func cacheCurrentWaveform() {
        
        guard let audioFile = self.audioFile else {return}
        
        let entry: WaveformCacheEntry = .init(audioFile: audioFile, imageSize: bounds.size)
        let dataFile = Self.cacheBaseDirectory.appendingPathComponent("\(entry.uuid).json")
        let data = WaveformCacheData(samples: self.samples)
        
        if Self.cache[audioFile] == nil {
            Self.cache[audioFile] = ConcurrentArray()
        }
        
        // Add it to the cache, mapped to the audio file.
        Self.cache[audioFile]?.append(entry)

//        cache[]
        DispatchQueue.global(qos: .background).async {
            self.save(data, toFile: dataFile)
        }
    }
    
    func lookUpCache(forFile file: URL) -> WaveformCacheLookup? {
        
        if let array = Self.cache[file] {
            
            for entry in array.array {
                
                if entry.imageSize == bounds.size {
                    
                    print("Cache HIT for file: \(file.lastPathComponent) !")
                    let dataFile = Self.cacheBaseDirectory.appendingPathComponent("\(entry.uuid).json")
                    
                    if let data = self.load(type: WaveformCacheData.self, fromFile: dataFile) {
                        return WaveformCacheLookup(entry: entry, data: data)
                        
                    } else {
                        print("Couldn't get data")
                    }
                    
                } else {
                    print("Cache MISS for file: \(file.lastPathComponent) !")
                }
            }
        }
        
        return nil
    }
    
    fileprivate func save<S>(_ state: S, toFile file: URL) where S: Codable {
        
        file.parentDir.createDirectory()
        
        do {
            
            let data = try encoder.encode(state)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                try jsonString.write(to: file, atomically: true, encoding: .utf8)
            } else {
                NSLog("Error saving app state config file: Unable to create String from JSON data.")
            }
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    func load<S>(type: S.Type, fromFile file: URL) -> S? where S: Codable {
        
        do {
            
            let jsonString = try String(contentsOf: file, encoding: .utf8)
            guard let jsonData = jsonString.data(using: .utf8) else {return nil}
            return try decoder.decode(S.self, from: jsonData)
            
        } catch let error as NSError {
            NSLog("Error loading app state config file: %@", error.description)
        }
        
        return nil
    }
}
//
//    // MARK: State and helper objects
//    
//    #if os(macOS)
//    
//    ///
//    /// NOTE - On macOS, since the windows are resizable, there can potentially be a large number of cached images per audio file, one per canvas size.
//    ///
//
//    ///
//    /// A cache containing mappings of audio file URL -> image file URL.
//    ///
//    /// A successful lookup (i.e. hit) in this cache will require a disk read to load the image file into memory, before it can be displayed
//    /// in the UI.
//    ///
//    static let cache: ConcurrentMap<URL, ConcurrentArray<WaveformImageCacheEntry>> = ConcurrentMap()
//    
//    #elseif os(iOS)
//    
//    ///
//    /// NOTE - On iPad devices, there may be up to 2 images in the cache per audio file: 1 - landscape orientation image, 2 - portrait orientation image.
//    ///
//    
//    ///
//    /// A cache of image file URLs mapped to a composite key consisting of 1 - the corresponding audio file URL, and
//    /// 2 - the size at which the image was rendered.
//    ///
//    /// A successful lookup (i.e. hit) in this cache will require a disk read to load the image file into memory, before it can be displayed
//    /// in the UI.
//    ///
//    static let cache: ConcurrentCompositeKeyMap<URL, CGSize, WaveformImageCacheEntry> = ConcurrentCompositeKeyMap()
//    
//    #endif
//    
//    /// Has the cache begun to initialize ?
//    static var cacheWillInitialize: Bool = false
//    
//    /// A **parallel** operation queue for reading / writing multiple cached images to / from disk concurrently.
//    static let diskIOOpQueue: OperationQueue = OperationQueue(concurrentOpCount: System.physicalCores,
//                                                              qualityOfService: .utility)
//    
//    ///
//    /// A **serial** operation queue to perform atomic updates to **UserDefaults**, one at a time.
//    ///
//    /// - Important:    We must ensure that only one UserDefaults update occurs at any given time, to
//    ///                 prevent data corruption.
//    ///
//    static let defaultsUpdateQueue: OperationQueue = OperationQueue(concurrentOpCount: 1,
//                                                                    qualityOfService: .utility)
//    
//    // ---------------------------------------------------------------------------------------------------------
//    
//    // MARK: Constants
//    
//    /// Number of bytes in a Kilobyte.
//    static let KB_bytes: UInt64 = 1024
//    
//    /// Number of bytes in a Megabyte.
//    static let MB_bytes: UInt64 = KB_bytes * 1024
//    
//    /// Number of bytes in a Gigabyte.
//    static let GB_bytes: UInt64 = MB_bytes * 1024
//    
//    /// Maximum total size of the on-disk waveform image cache, in bytes.
//    #if os(macOS)
//    static let diskUsageLimit: UInt64 = 1 * GB_bytes          // 1 GB
//    #elseif os(iOS)
//    static let diskUsageLimit: UInt64 = 500 * MB_bytes        // 500 MB
//    #endif
//    
//    /// The base directory to which cached waveform images will be written.
//    static let cacheBaseDirectory: URL = URL.userDocumentsDirectory.appendingPathComponent(".WaveformImageCache", isDirectory: true)
//    
//    // ---------------------------------------------------------------------------------------------------------
//    
//    // MARK: Cache initialization
//    
//    ///
//    /// Initializes the waveform image cache (on a background thread).
//    ///
//    public static func initializeImageCache() {
//        
//        // If initialization has already begun, don't do anything,
//        // i.e., this should be done only once.
//        
//        if cacheWillInitialize {return}
//        
//        cacheWillInitialize = true
//        
//        DispatchQueue.global(qos: .utility).async {
//            
//            guard cacheBaseDirectory.exists else {
//             
//                // Create the base directory and remove any potentially
//                // existing (orphaned) entries in UserDefaults.
//                
//                cacheBaseDirectory.createDirectory()
//                removeAllDefaultsEntries()
//                
//                return
//            }
//            
//            // Read entries from UserDefaults, and populate the cache with them.
//            var entries: [WaveformImageCacheEntry] = imageCacheEntries
//            let indicesOfInvalidEntries: ConcurrentArray<Int> = ConcurrentArray()
//            
//            for (index, entry) in entries.enumerated() {
//                
//                #if os(macOS)
//                
//                // NOTE - Always standardize the URL (to remove symlinks) when storing entries in
//                // the in-memory cache.
//                
//                let standardizedFileURL = entry.audioFile.resolvedAndStandardized
//                
//                // If there is no existing map entry for this audio file, place an empty array in the map.
//                if cache[standardizedFileURL] == nil {
//                    cache[standardizedFileURL] = ConcurrentArray()
//                }
//                
//                // Add it to the cache, mapped to the audio file.
//                cache[standardizedFileURL]?.append(entry)
//                
//                #elseif os(iOS)
//                
//                // This needs to be done async because URLs need to be resolved
//                // from bookmark data ... i.e. a potentially time consuming
//                // operation.
//                
//                diskIOOpQueue.addOperation {
//                
//                    // We must first resolve the audio file URL bookmark data
//                    // to a URL, then we can add the entry to the cache, mapped to the
//                    // audio file and the rendered image size.
//                    
//                    if let audioFile = entry.audioFile {
//                        
//                        // NOTE - Always standardize the URL (to remove symlinks) when storing entries in
//                        // the in-memory cache.
//                        
//                        let standardizedFileURL = audioFile.resolvedAndStandardized
//                        cache[standardizedFileURL, entry.imageSize] = entry
//                        
//                    } else {
//                        indicesOfInvalidEntries.append(index)
//                    }
//                }
//                
//                #endif
//            }
//            
//            // Remove all invalid entries from the cache.
//            #if os(iOS)
//            
//            if indicesOfInvalidEntries.count > 0 {
//                
//                diskIOOpQueue.waitUntilAllOperationsAreFinished()
//                
//                defaultsUpdateQueue.addOperation {
//                    
//                    // Sort indices in descending order before removing entries.
//                    for index in indicesOfInvalidEntries.array.sorted(by: >) {
//                        entries.remove(at: index)
//                    }
//                    
//                    imageCacheEntries = entries
//                }
//            }
//            
//            #endif
//        }
//    }
//    
//    ///
//    /// Clears the image cache completely.
//    ///
//    static func clearImageCache() {
//        
//        Self.cache.removeAll()
//        removeAllDefaultsEntries()
//        cacheBaseDirectory.delete()
//        cacheBaseDirectory.createDirectory()
//    }
//}
//
//// ----------------------------------------------------------------------------------------------------------------
//
//// MARK: Utility
//
/////
///// ``Hashable`` conformance is required for use as a key in a composite key map.
/////
//extension CGSize: Hashable {
//    
//    ///
//    /// Computes a hash to uniquely identify a ``CGSize``.
//    ///
//    public func hash(into hasher: inout Hasher) {
//    
//        // The hash is a function of the width and height.
//        hasher.combine(self.width)
//        hasher.combine(self.height)
//    }
//}
