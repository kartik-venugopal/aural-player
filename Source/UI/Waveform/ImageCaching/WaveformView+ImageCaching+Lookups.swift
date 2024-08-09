////
////  WaveformView+ImageCaching+Lookups.swift
////  Periphony: Spatial Audio Player
////  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
////  Developed by Kartik Venugopal
////
//
//import Foundation
//import CoreGraphics
//
/////
///// Part of ``WaveformView`` that deals with waveform image cache lookups.
/////
//extension WaveformView {
//    
//    ///
//    /// Retrieves cached waveform image state for the given audio file and target image size.
//    ///
//    func cacheLookup(forFile file: URL, atSize size: CGSize) -> WaveformRenderState? {
//        
//        // NOTE - Always standardize the URL (to remove symlinks) when searching
//        // the in-memory cache.
//        
//        let file = file.resolvedAndStandardized
//        
//        #if os(macOS)
//        
//        // Check for any entries for this audio file.
//        guard let candidates = Self.cache[file] else {return nil}
//        
//        // Filter and sort the candidates to determine which candidate, if any, is the best match for this lookup.
//        let matches: [WaveformImageCacheEntry] = filterAndSortLookupCandidates(candidates.array, atSize: size)
//        
//        // The first match in the sorted array of matches is the best match.
//        // NOTE - It may be nil, if no suitable matches were found.
//        
//        // If a match is found, load the corresponding image file from disk.
//        
//        guard let match = matches.first else {return nil}
//        
//        #elseif os(iOS)
//        
//        guard let match: WaveformImageCacheEntry = Self.cache[file, size] else {
//            return nil
//        }
//        
//        #endif
//        
//        guard let renderState = match.toWaveformRenderState() else {return nil}
//        
//        // Update the "last opened" timestamp for this cache entry (used for LRU comparisons).
//        Self.updateLastOpenedTimestamp(forEntry: match)
//        
//        return renderState
//    }
//    
//    #if os(macOS)
//    
//    ///
//    /// Filters and sorts the given array of cache entry lookup results (i.e. "candidates"), to determine which candidate, if any,
//    /// is the best match for the lookup.
//    ///
//    private func filterAndSortLookupCandidates<T: WaveformImageCacheable>(_ candidates: [T], atSize targetSize: CGSize) -> [T] {
//        
//        return candidates.filter {candidate in
//            
//            // Step 1 - Filter candidates by checking if their image size
//            // fits into the allowed horizontal and vertical overdraw ranges.
//            
//            let horizOverdraw = candidate.imageSize.width / frame.width
//            let vertOverdraw = candidate.imageSize.height / frame.height
//            
//            return horizontalOverdrawAllowed.contains(horizOverdraw) && verticalOverdrawAllowed.contains(vertOverdraw)
//            
//        }.sorted(by: {entry1, entry2 in
//            
//            // Step 2 - Sort candidates in ascending order by difference in image size
//            // from the target image size. The entry that is closest in size to the
//            // target image size will end up at index 0 and will represent the best
//            // match.
//            
//            let widthDelta1 = abs(entry1.imageSize.width - targetSize.width)
//            let heightDelta1 = abs(entry1.imageSize.height - targetSize.height)
//            
//            let widthDelta2 = abs(entry2.imageSize.width - targetSize.width)
//            let heightDelta2 = abs(entry2.imageSize.height - targetSize.height)
//            
//            return (widthDelta1 * heightDelta1) < (widthDelta2 * heightDelta2)
//        })
//    }
//    
//    #endif
//}
