//
//  WaveformAudioContext.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AVFoundation
import OSLog

///
/// A container for audio information used for building waveforms.
///
final class WaveformAudioContext {
    
    // MARK: State
    
    /// The audio asset URL used to load the context.
    public let audioFile: URL
    
    /// Total number of samples in the loaded asset.
    public let totalSamples: Int
    
    public let channelCount: Int
    
    ///
    /// ``AVFoundation`` information for the audio file.
    ///
    /// **Notes**
    ///
    /// This will be available (non-nil) only for files supported by
    /// ``AVFoundation`` (i.e. WAV / CAF).
    ///
    public let avfFile: AVFAudioContext?
    
    public let ffmpegDecoder: FFmpegWaveformDecoder?
    
    // ------------------------------------------------------------------------------------------
    
    // MARK: Initializers
    
    ///
    /// Initializer for ``AVFoundation`` audio files.
    ///
    private init(avfFile: AVFAudioContext) {
        
        self.audioFile = avfFile.file
        self.totalSamples = avfFile.totalSamples
        self.channelCount = avfFile.channelCount
        self.avfFile = avfFile
        self.ffmpegDecoder = nil
    }
    
    private init(ffmpegDecoder: FFmpegWaveformDecoder) {
        
        self.audioFile = ffmpegDecoder.fileCtx.file
        self.totalSamples = Int(floor(ffmpegDecoder.duration * ffmpegDecoder.sampleRateDouble))
        self.channelCount = ffmpegDecoder.channelCount
        self.avfFile = nil
        self.ffmpegDecoder = ffmpegDecoder
    }
    
    // ------------------------------------------------------------------------------------------
    
    // MARK: Exposed functions
    
    ///
    /// Asynchronously loads audio information for the given file, executing the given completion handler block
    /// with the result upon completion of the information retrieval.
    ///
    public static func load(fromAudioFile audioFile: URL, completionHandler: @escaping (_ audioContext: WaveformAudioContext?) -> ()) {
       
        // Check the type of file to determine how to load information.
        
        if audioFile.isNativelySupported {
            loadAVFContext(fromAudioFile: audioFile, completionHandler: completionHandler)
            
        } else if audioFile.isSupportedAudioFile {
            loadFFmpegContext(fromAudioFile: audioFile, completionHandler: completionHandler)
            
        } else {
            completionHandler(nil)
        }
    }
    
    private static func loadFFmpegContext(fromAudioFile audioFile: URL, completionHandler: @escaping (_ audioContext: WaveformAudioContext?) -> ()) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            do {
                
                let ffmpegDecoder = try FFmpegWaveformDecoder(for: audioFile, chunkSize: Int(WaveformRenderOperation.chunkSize))
                completionHandler(WaveformAudioContext(ffmpegDecoder: ffmpegDecoder))
                
            } catch {
                completionHandler(nil)
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    // MARK: Private functions
    
    ///
    /// Asynchronously loads audio information for an ``AVFoundation`` file, executing the given completion handler block
    /// with the result upon completion of the information retrieval.
    ///
    private static func loadAVFContext(fromAudioFile audioFile: URL, completionHandler: @escaping (_ audioContext: WaveformAudioContext?) -> ()) {
        
        let asset = AVURLAsset(url: audioFile, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true as Bool)])
        
        guard let assetTrack = asset.tracks(withMediaType: .audio).first else {
            
            NSLog("WaveformView failed to load AVAssetTrack")
            completionHandler(nil)
            return
        }
        
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            
            var error: NSError?
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            
            switch status {
                
            case .loaded:
                
                // Read sample count, channel count, and sample rate from the asset.
                
                guard
                    let formatDescriptions = assetTrack.formatDescriptions as? [CMAudioFormatDescription],
                    let audioFormatDesc = formatDescriptions.first,
                    let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDesc)
                    else { break }
                
//                let totalSamples = Int((asbd.pointee.mSampleRate) * Float64(asset.duration.value) / Float64(asset.duration.timescale))
                guard let avAudioFile = try? AVAudioFile(forReading: audioFile) else {return}
                print("Duration: \(Int(Double(avAudioFile.length) / avAudioFile.processingFormat.sampleRate))")
                
                let totalSamples = avAudioFile.length
                
                var channelCount = 1
                var sampleRate: CMTimeScale = 44100
                
                for item in formatDescriptions {
                    
                    guard let fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item) else {
                        
                        completionHandler(nil)
                        return
                    }
                    
                    channelCount = Int(fmtDesc.pointee.mChannelsPerFrame)
                    sampleRate = Int32(fmtDesc.pointee.mSampleRate)
                }
                
                // Construct an audio context object and invoke the completion handler with the loaded information.
                
                let avfFile = AVFAudioContext(file: audioFile, avfAsset: asset, avfAssetTrack: assetTrack, audioFile: avAudioFile,
                                      channelCount: channelCount, sampleRate: sampleRate, totalSamples: Int(totalSamples))
                
                let audioContext = WaveformAudioContext(avfFile: avfFile)
                completionHandler(audioContext)
                
                return
                
            case .failed, .cancelled, .loading, .unknown:
                break
//                logger.error("WaveformView could not load asset: \(error?.localizedDescription ?? "Unknown error")")
                
            @unknown default:
                break
                
//                logger.error("WaveformView could not load asset: \(error?.localizedDescription ?? "Unknown error")")
            }
            
            completionHandler(nil)
        }
    }
}
