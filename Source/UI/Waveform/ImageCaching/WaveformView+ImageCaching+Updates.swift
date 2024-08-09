////
////  WaveformView+ImageCaching+Updates.swift
////  Periphony: Spatial Audio Player
////  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
////  Developed by Kartik Venugopal
////
//
//import Foundation
//import CoreGraphics
//
/////
///// Part of ``WaveformView`` that deals with waveform image cache updates.
/////
//extension WaveformView {
//    
//    ///
//    /// Adds the given (new) entry to the cache, i.e. persists
//    /// it to ``UserDefaults``, and writes its corresponding image file to disk.
//    ///
//    /// **Notes**
//    ///
//    /// This function will be called after a waveform image has
//    /// just been rendered, to speed up potential future lookups.
//    ///
//    func addToCache(state: WaveformRenderState) {
//        
//        Self.diskIOOpQueue.addOperation {
//            
//            let audioFileURL = state.audioFile
//            let standardizedURL = audioFileURL.resolvedAndStandardized
//            
//            // Use a UUID to ensure that the image file name is always unique.
//            
//            let imageFileName = UUID().uuidString
//            let outputFile = Self.cacheBaseDirectory.appendingPathComponent("\(imageFileName).png")
//            
//            do {
//                
//                // ---------------------------------------------------------------------------------------------------------
//                
//                // Step 1 - Write the image to disk.
//                
//                try state.renderOutput?.writeAsPNGToFile(file: outputFile)
//                
//                // ---------------------------------------------------------------------------------------------------------
//                
//                // Step 2 - Store the new entry in UserDefaults.
//                
//                #if os(macOS)
//                
//                // Create a new cache entry.
//                
//                let newEntry = WaveformImageCacheEntry(audioFile: standardizedURL, imageFile: outputFile, imageFileSize: outputFile.size,
//                                                       imageSize: state.imageSize, scale: state.options.scale, sampleRange: state.sampleRange,
//                                                       scaleFactor: state.options.scaleFactor)
//                
//                #elseif os(iOS)
//                
//                // Create a new cache entry with bookmark data for the audio and image files.
//                
//                let audioFileBookmark = try audioFileURL.bookmarkData()
//                let outputFileBookmark = try outputFile.bookmarkData()
//                
//                let newEntry = WaveformImageCacheEntry(audioFileBookmark: audioFileBookmark, imageFileBookmark: outputFileBookmark,
//                                                       imageFileSize: outputFile.size, imageSize: state.imageSize,
//                                                       scale: state.options.scale, sampleRange: state.sampleRange, scaleFactor: state.options.scaleFactor)
//                
//                #endif
//                
//                Self.saveNewEntryToDefaults(newEntry)
//                
//                // ---------------------------------------------------------------------------------------------------------
//                
//                // Step 3 - Store the new entry in the in-memory cache.
//                
//                // NOTE - Always standardize the URL (to remove symlinks) when storing entries in
//                // the in-memory cache.
//                
//                #if os(macOS)
//                
//                // If there is no existing map entry for this audio file, place an empty array in the map.
//                if Self.cache[standardizedURL] == nil {
//                    Self.cache[standardizedURL] = ConcurrentArray()
//                }
//                
//                // Add it to the cache, mapped to the audio file.
//                Self.cache[standardizedURL]?.append(newEntry)
//                
//                #elseif os(iOS)
//                
//                Self.cache[standardizedURL, state.imageSize] = newEntry
//                
//                #endif
//                
//                // ---------------------------------------------------------------------------------------------------------
//                
//                // Step 4 - Cull the on-disk cache to ensure that it does not exceed its size limit.
//                
//                Self.performOnDiskCacheCulling()
//                
//            } catch {
//                NSLog("Failed to write image to file. Error: \(error)")
//            }
//        }
//    }
//    
//    ///
//    /// Invalidates any existing cache entries for the given audio file, so that no subsequent cache lookups will
//    /// produce those entries.
//    ///
//    func invalidateCacheEntries(forFile file: URL) {
//        
//        // Step 1 - Remove the entries from the in-memory cache.
//        guard let cacheHit = Self.cache.removeValue(forKey: file) else {
//            return
//        }
//        
//        #if os(macOS)
//        let entriesToDelete = cacheHit.array
//        #elseif os(iOS)
//        let entriesToDelete = Array(cacheHit.values)
//        #endif
//        
//        // Step 2 - Remove the entries from UserDefaults.
//        Self.deleteEntriesFromDefaults(entriesToDelete)
//        
//        // Step 3 - Delete the associated image files from disk.
//        for entry in entriesToDelete {
//            
//            #if os(iOS)
//            entry.imageFile?.delete()
//            #elseif os(macOS)
//            entry.imageFile.delete()
//            #endif
//        }
//    }
//    
//    // ---------------------------------------------------------------------------------------------------------
//    
//    // MARK: Helper functions
//    
//    ///
//    /// Updates the "last opened" timestamp for the cache entry corresponding to the given
//    /// audio file URL.
//    ///
//    /// This function should be called immediately after a successful lookup has been performed
//    /// or an image has just been rendered from scratch.
//    ///
//    /// This timestamp helps with LRU comparisons when performing cache culling.
//    ///
//    static func updateLastOpenedTimestamp(forEntry entry: WaveformImageCacheEntry) {
//        
//        // Add this to the serial queue, because we want at most 1 such update
//        // to execute at any given time (otherwise, the cache entries could get
//        // corrupted).
//        
//        defaultsUpdateQueue.addOperation {
//            
//            // Get all existing entries.
//            let entries = imageCacheEntries
//            
//            // Search for an entry corresponding to the given audio file.
//            if let matchingEntry = entries.first(where: {$0.uuid == entry.uuid}) {
//                
//                // Update the timestamp.
//                matchingEntry.updateLastOpenedTimestamp()
//                
//                // Persist the change.
//                imageCacheEntries = entries
//            }
//        }
//    }
//    
//    ///
//    /// Checks current disk space usage by the cache, and culls it (i.e. deletes least recently used entries)
//    /// if necessary, i.e. if current usage exceeds the predetermined size limit.
//    ///
//    private static func performOnDiskCacheCulling() {
//        
//        // Perform this on the serial update queue, to prevent corruption of
//        // UserDefaults cache entries.
//        
//        defaultsUpdateQueue.addOperation {
//            
//            // Read entries from UserDefaults, sorting by last opened time (most recently opened entries first).
//            var entries = imageCacheEntries.sorted(by: {$0.lastOpenedTimestamp > $1.lastOpenedTimestamp})
//            
//            // Keep track of cache size while iterating through entries.
//            var cacheSizeSoFar: UInt64 = 0
//            
//            for (index, entry) in entries.enumerated() {
//                
//                cacheSizeSoFar += entry.imageFileSize
//                
//                if cacheSizeSoFar > diskUsageLimit {
//                    
//                    // Remove all entries including and past this index
//                    // because keeping them on disk will cause the
//                    // cache to exceed its size limit.
//                    
//                    for entryToDelete in entries[index..<entries.count] {
//                        
//                        // Delete the image file from disk.
//                        
//                        #if os(macOS)
//                        entryToDelete.imageFile.delete()
//                        #elseif os(iOS)
//                        entryToDelete.imageFile?.delete()
//                        #endif
//                    }
//                    
//                    // Remove the corresponding entries from UserDefaults, and persist
//                    // the change.
//                    
//                    entries.removeSubrange(index..<entries.count)
//                    imageCacheEntries = entries
//                    
//                    break
//                }
//            }
//        }
//    }
//}
