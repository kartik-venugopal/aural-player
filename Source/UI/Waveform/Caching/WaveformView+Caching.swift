//
//  WaveformView+Caching.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension WaveformView {
    
    static let cacheBaseDirectory: URL = FilesAndPaths.subDirectory(named: "waveformCache")
    static let cache: ConcurrentMap<URL, ConcurrentArray<WaveformCacheEntry>> = ConcurrentMap()
    static let dataCache: ConcurrentMap<String, WaveformCacheData> = ConcurrentMap()
    
    static var persistentState: WaveformPersistentState {
        WaveformPersistentState(cacheEntries: cache.map.values.flatMap {$0.array})
    }
    
    static func initializeImageCache() {
        
        DispatchQueue.global(qos: .utility).async {
            
            guard cacheBaseDirectory.exists else {
                
                cacheBaseDirectory.createDirectory()
                
                // If the directory doesn't exist, that implies no files to read.
                return
            }
            
            guard let persistentState = appPersistentState.ui?.waveform?.cacheEntries else {return}
            
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
    
    static func addToCache(waveformData data: [[Float]], forAudioFile audioFile: URL, renderedForImageSize imageSize: NSSize) {
        
        let entry: WaveformCacheEntry = .init(audioFile: audioFile, imageSize: imageSize)
        let dataFile = cacheBaseDirectory.appendingPathComponent("\(entry.uuid).json")
        let data = WaveformCacheData(samples: data)
        
        if cache[audioFile] == nil {
            cache[audioFile] = ConcurrentArray()
        }
        
        // Add it to the cache, mapped to the audio file.
        cache[audioFile]?.append(entry)
        dataCache[entry.uuid] = data
        
        DispatchQueue.global(qos: .background).async {
            data.save(toFile: dataFile)
        }
    }
    
    static func lookUpCache(forFile file: URL, matchingImageSize imageSize: NSSize) -> WaveformCacheLookup? {
        
        guard let entryMatchingImageSize = cache[file]?.array.first(where: {$0.imageSize == imageSize}) else {
            return nil
        }
        
        entryMatchingImageSize.updateLastOpenedTimestamp()
        
        if let inMemoryData = dataCache[entryMatchingImageSize.uuid] {
            return WaveformCacheLookup(entry: entryMatchingImageSize, data: inMemoryData)
        }
        
        let dataFile = cacheBaseDirectory.appendingPathComponent("\(entryMatchingImageSize.uuid).json")
        
        if let data = WaveformCacheData.load(fromFile: dataFile) {
            return WaveformCacheLookup(entry: entryMatchingImageSize, data: data)
        }
        
        return nil
    }
}
