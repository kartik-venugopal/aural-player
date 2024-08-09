////
////  WaveformView+ImageCaching+UserDefaults.swift
////  Periphony: Spatial Audio Player
////  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
////  Developed by Kartik Venugopal
////
//
//import Foundation
//
/////
///// Part of ``WaveformView`` that deals with reading / writing of waveform image
///// cache entries to / from ``UserDefaults``.
/////
//extension WaveformView {
//    
//    /// The ``UserDefaults`` key to which the on-disk cache entries will be mapped.
//    private static let cacheDefaultsKey: String = "waveformView.imageCache"
//    
//    ///
//    /// Gets / sets all existing cache entries to / from ``UserDefaults``.
//    ///
//    static var imageCacheEntries: [WaveformImageCacheEntry] {
//        
//        get {
//            jsonDecoder.decode([WaveformImageCacheEntry].self, mappedToDefaultsKey: cacheDefaultsKey) ?? []
//        }
//        
//        set {
//            jsonEncoder.encode(newValue, mappedToDefaultsKey: cacheDefaultsKey)
//        }
//    }
//    
//    ///
//    /// Saves the given (new) cache entry to ``UserDefaults``.
//    ///
//    static func saveNewEntryToDefaults(_ entry: WaveformImageCacheEntry) {
//        
//        // Do this on the serial update queue to prevent data corruption.
//        
//        defaultsUpdateQueue.addOperation {
//            
//            // Step 1 - Get existing entries.
//            // Step 2 - Append the new entry.
//            // Step 3 - Persist the modified entries array.
//            
//            var entries = imageCacheEntries
//            entries.append(entry)
//            imageCacheEntries = entries
//        }
//        
//        // Wait until the new entry has been persisted.
//        defaultsUpdateQueue.waitUntilAllOperationsAreFinished()
//    }
//    
//    ///
//    /// Deletes the given cache entry from ``UserDefaults``.
//    ///
//    static func deleteEntriesFromDefaults(_ entriesToDelete: [WaveformImageCacheEntry]) {
//        
//        defaultsUpdateQueue.addOperation {
//            
//            /// Quick lookup map for better performance.
//            /// UUID -> entry
//            var entriesMap: [String: WaveformImageCacheEntry] = [:]
//            
//            // Step 1 - Get existing entries.
//            for entry in imageCacheEntries {
//                entriesMap[entry.uuid] = entry
//            }
//            
//            for entryToDelete in entriesToDelete {
//
//                // Step 2 - Find the matching entry (by UUID), and delete it from the collection.
//                entriesMap.removeValue(forKey: entryToDelete.uuid)
//            }
//            
//            // Step 3 - Persist the modified entries collection.
//            imageCacheEntries = Array(entriesMap.values)
//        }
//    }
//    
//    ///
//    /// Removes all cache entries from ``UserDefaults``.
//    ///
//    static func removeAllDefaultsEntries() {
//        
//        // Remove any (potentially) orphaned cache entries from UserDefaults.
//        defaults.removeObject(forKey: cacheDefaultsKey)
//    }
//}
