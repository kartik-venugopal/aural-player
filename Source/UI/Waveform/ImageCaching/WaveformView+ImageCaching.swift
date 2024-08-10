////
////  WaveformView+ImageCaching.swift
////  Periphony: Spatial Audio Player
////  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
////  Developed by Kartik Venugopal
////
//
import Foundation
//import CoreGraphics

extension WaveformView {
    
    static let cacheBaseDirectory: URL = FilesAndPaths.subDirectory(named: "waveformCache")
    
    static let cache: ConcurrentMap<URL, ConcurrentArray<WaveformCacheEntry>> = ConcurrentMap()
    static let dataCache: ConcurrentMap<String, WaveformCacheData> = ConcurrentMap()
    
    static var persistentState: WaveformPersistentState {
        WaveformPersistentState(entries: cache.map.values.flatMap {$0.array})
    }
    
    public static func initializeImageCache() {
        
        DispatchQueue.global(qos: .utility).async {
            
            guard cacheBaseDirectory.exists else {
                
                cacheBaseDirectory.createDirectory()
                
                // If the directory doesn't exist, that implies no files to read.
                return
            }
            
            guard let persistentState = appPersistentState.ui?.waveform?.entries else {return}
            
            for entry in persistentState {
                
                guard let newEntry = WaveformCacheEntry(persistentState: entry) else {continue}
                
                let audioFile = newEntry.audioFile
                
                if cache[audioFile] == nil {
                    cache[audioFile] = ConcurrentArray()
                }
                
                cache[audioFile]?.append(newEntry)
                
                let dataFile = cacheBaseDirectory.appendingPathComponent("\(newEntry.uuid).json")
                
                if let data = WaveformCacheData.load(fromFile: dataFile) {
                    dataCache[newEntry.uuid] = data
                }
            }
        }
    }
    
    func cacheCurrentWaveform() {
        
        guard let audioFile = self.audioFile else {return}
        
        let entry: WaveformCacheEntry = .init(audioFile: audioFile, imageSize: waveformSize)
        let dataFile = Self.cacheBaseDirectory.appendingPathComponent("\(entry.uuid).json")
        let data = WaveformCacheData(samples: samples)
        
        if Self.cache[audioFile] == nil {
            Self.cache[audioFile] = ConcurrentArray()
        }
        
        // Add it to the cache, mapped to the audio file.
        Self.cache[audioFile]?.append(entry)
        Self.dataCache[entry.uuid] = data

        DispatchQueue.global(qos: .background).async {
            data.save(toFile: dataFile)
        }
    }
    
    func lookUpCache(forFile file: URL) -> WaveformCacheLookup? {
        
        guard let entryMatchingImageSize = Self.cache[file]?.array.first(where: {$0.imageSize == bounds.size}) else {return nil}
        entryMatchingImageSize.updateLastOpenedTimestamp()
        
        if let inMemoryData = Self.dataCache[entryMatchingImageSize.uuid] {
            return WaveformCacheLookup(entry: entryMatchingImageSize, data: inMemoryData)
        }
        
        let dataFile = Self.cacheBaseDirectory.appendingPathComponent("\(entryMatchingImageSize.uuid).json")
        
        if let data = WaveformCacheData.load(fromFile: dataFile) {
            return WaveformCacheLookup(entry: entryMatchingImageSize, data: data)
            
        } else {
            
            NSLog("Couldn't get data from disk for file: \(dataFile.path)")
            return nil
        }
    }
}
