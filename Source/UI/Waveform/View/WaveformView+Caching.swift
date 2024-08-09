//
//  WaveformView+Caching.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import CoreGraphics

///
/// Part of ``WaveformView`` that evaluates current cache status in order
/// to determine whether the cached (or currently rendering) waveform
/// image is suitable for display in the view or if a fresh render of the waveform is
/// required, taking into consideration the current frame of the view and the options
/// used to render the cached (or currently rendering) waveform.
///
extension WaveformView {
    
//    // MARK: Exposed members
//    
//    ///
//    /// Current cache status.
//    ///
//    /// - SeeAlso:   ``CacheStatus``
//    ///
//    var cacheStatus: CacheStatus {
//        
//        // If the window containing this view is currently being resized, we want to prevent
//        // any renders from taking place, as they will be invalidated anyway by subsequent
//        // resize events (we don't know the final size of the window when resizing ends).
//        // So, always return a value of `notDirty` during window resizing.
//        
//        if windowResizeInProgress {return .notDirty(cancelInProgressRenderOperation: true)}
//        
//        // If the most recent render failed, don't attempt another redraw, so return ``notDirty``.
//        guard !renderForCurrentAssetFailed else {return .notDirty(cancelInProgressRenderOperation: true)}
//
//        let isInProgressRenderOperationDirty = isWaveformRenderOperationDirty(inProgressWaveformRenderOperation)
//        let isCachedRenderOperationDirty = isWaveformRenderStateDirty(cachedWaveformRenderState)
//
//        if let isInProgressRenderOperationDirty = isInProgressRenderOperationDirty {
//            
//            if let isCachedRenderOperationDirty = isCachedRenderOperationDirty {
//                
//                if isInProgressRenderOperationDirty {
//                    
//                    if isCachedRenderOperationDirty {
//                        return .dirty
//                    } else {
//                        return .notDirty(cancelInProgressRenderOperation: true)
//                    }
//                    
//                } else if !isCachedRenderOperationDirty {
//                    return .notDirty(cancelInProgressRenderOperation: true)
//                }
//                
//            } else if isInProgressRenderOperationDirty {
//                return .dirty
//            }
//            
//        } else if let isLastWaveformRenderOperationDirty = isCachedRenderOperationDirty {
//            
//            if isLastWaveformRenderOperationDirty {
//                return .dirty
//            }
//            
//        } else {
//            return .dirty
//        }
//
//        return .notDirty(cancelInProgressRenderOperation: false)
//    }
//    
//    // -----------------------------------------------------------------------------------------------
//    
//    // MARK: Helper functions
//
//    ///
//    /// Checks if the state associated with the given waveform render operation indicates
//    /// a dirty cache.
//    ///
//    private func isWaveformRenderOperationDirty(_ renderOperation: WaveformRenderOperation?) -> Bool? {
//        
//        guard let renderOperation = renderOperation else {return nil}
//
//        return isWaveformRenderStateDirty(options: renderOperation.options, sampleRange: renderOperation.sampleRange,
//                                          imageSize: renderOperation.imageSize)
//    }
//    
//    ///
//    /// Checks if the given waveform render state indicates a dirty cache.
//    ///
//    private func isWaveformRenderStateDirty(_ renderState: WaveformRenderState?) -> Bool? {
//        
//        guard let renderState = renderState else {return nil}
//
//        return isWaveformRenderStateDirty(options: renderState.options, sampleRange: renderState.sampleRange,
//                                          imageSize: renderState.imageSize)
//    }
//    
//    ///
//    /// Checks if the given waveform render options indicate a dirty cache.
//    ///
//    /// - Parameter options:        The options used to render the cached / rendering waveform.
//    ///
//    /// - Parameter sampleRange:    The sample range for which the the cached / rendering waveform was / is being drawn.
//    ///
//    /// - Parameter imageSize:      The dimensions of the cached / rendering waveform image.
//    ///
//    private func isWaveformRenderStateDirty(options: WaveformRenderOptions, sampleRange: CountableRange<Int>, imageSize: CGSize) -> Bool {
//        
//        // If the scale option doesn't match the current scale, the cache is dirty.
//        if options.scale != waveformRenderScale {
//            return true
//        }
//        
//        // If the scale factor option doesn't match the current scale factor, the cache is dirty.
//        if options.scaleFactor != desiredImageScale {
//            return true
//        }
//        
//        // Disabled for v1.0.
////        if format.renderMode != renderMode {
////            return true
////        }
//
//        // If the cached / rendering waveform's sample range doesn't contain the currently required sample range, the cache is dirty.
//        
//        let requiredSamples = zoomSamples.extended(byFactor: horizontalBleedAllowed.lowerBound).clamped(to: 0 ..< totalSamples)
//        if requiredSamples.clamped(to: sampleRange) != requiredSamples {
//            return true
//        }
//
//        let allowedSamples = zoomSamples.extended(byFactor: horizontalBleedAllowed.upperBound).clamped(to: 0 ..< totalSamples)
//        if sampleRange.clamped(to: allowedSamples) != sampleRange {
//            return true
//        }
//        
//        // If the cached / rendering waveform's dimensions don't fit into the current overdraw range, the cache is dirty.
//        
//        let verticalOverdrawRequested = Double(imageSize.height / frame.height)
//        
//        if !verticalOverdrawAllowed.contains(verticalOverdrawRequested) {
//            return true
//        }
//        
//        let horizontalOverdrawRequested = Double(imageSize.width / frame.width)
//        
//        if !horizontalOverdrawAllowed.contains(horizontalOverdrawRequested) {
//            return true
//        }
//
//        return false
//    }
//    
//    // -----------------------------------------------------------------------------------------------
//    
//    // MARK: Auxiliary types
//    
//    ///
//    /// Enumerates the different possible values of waveform image cache status.
//    ///
//    /// Helps determine if the cached waveform or in-progress waveform is insufficient for the current frame.
//    ///
//    enum CacheStatus {
//        
//        /// The cached (or currently rendering) waveform is stale, i.e. a fresh render is required.
//        case dirty
//        
//        /// The cached (or currently rendering) waveform is suitable for display, i.e. no fresh
//        /// render is required.
//        case notDirty(cancelInProgressRenderOperation: Bool)
//    }
}
