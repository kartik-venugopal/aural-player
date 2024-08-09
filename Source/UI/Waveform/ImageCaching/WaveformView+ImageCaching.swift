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
            
            var ctr = 0
            
            for entry in persistentState {
                
                guard let newEntry = WaveformCacheEntry(persistentState: entry) else {continue}
                
                ctr.increment()
                
                let audioFile = newEntry.audioFile
                
                if cache[audioFile] == nil {
                    cache[audioFile] = ConcurrentArray()
                }
                
                cache[audioFile]?.append(newEntry)
                
                let dataFile = cacheBaseDirectory.appendingPathComponent("\(newEntry.uuid).json")
                
                if let data = load(type: WaveformCacheData.self, fromFile: dataFile) {
                    dataCache[newEntry.uuid] = data
                }
            }
            
            print("Initialized Waveform Cache with \(ctr) entries for files:")
            print(cache.map.keys.map {$0.path})
        }
    }
    
    func cacheCurrentWaveform() {
        
        guard let audioFile = self.audioFile else {return}
        
        let entry: WaveformCacheEntry = .init(audioFile: audioFile, imageSize: waveformSize)
        let dataFile = Self.cacheBaseDirectory.appendingPathComponent("\(entry.uuid).json")
        let data = WaveformCacheData(samples: self.samples)
        
        if Self.cache[audioFile] == nil {
            Self.cache[audioFile] = ConcurrentArray()
        }
        
        // Add it to the cache, mapped to the audio file.
        Self.cache[audioFile]?.append(entry)
        Self.dataCache[entry.uuid] = data

        DispatchQueue.global(qos: .background).async {
            Self.save(data, toFile: dataFile)
        }
    }
    
    func lookUpCache(forFile file: URL) -> WaveformCacheLookup? {
        
        guard let entryMatchingImageSize = Self.cache[file]?.array.first(where: {$0.imageSize == bounds.size}) else {return nil}
        
        print("Cache HIT for file: \(file.lastPathComponent) !")
        
        if let inMemoryData = Self.dataCache[entryMatchingImageSize.uuid] {
            
            print("IN-MEMORY Cache HIT for file: \(file.lastPathComponent) !")
            return WaveformCacheLookup(entry: entryMatchingImageSize, data: inMemoryData)
        }
        
        let dataFile = Self.cacheBaseDirectory.appendingPathComponent("\(entryMatchingImageSize.uuid).json")
        
        if let data = Self.load(type: WaveformCacheData.self, fromFile: dataFile) {
            return WaveformCacheLookup(entry: entryMatchingImageSize, data: data)
            
        } else {
            print("Couldn't get data from disk")
        }
        
        return nil
    }
    
    fileprivate static func save<S>(_ state: S, toFile file: URL) where S: Codable {
        
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
    
    fileprivate static func load<S>(type: S.Type, fromFile file: URL) -> S? where S: Codable {
        
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
