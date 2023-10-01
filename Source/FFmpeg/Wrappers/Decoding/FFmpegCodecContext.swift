//
//  FFmpegCodecContext.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FFmpegCodecContext {
    
    ///
    /// A pointer to a context for the encapsulated AVCodecContext object.
    ///
    var pointer: UnsafeMutablePointer<AVCodecContext>!
    
    ///
    /// The encapsulated AVCodecContext object.
    ///
    var avContext: AVCodecContext {pointer!.pointee}
    
    let codecID: AVCodecID
    
    var channelLayout: UInt64 {avContext.channel_layout}
    
    var channels: Int32 {avContext.channels}
    
    var sampleFormat: AVSampleFormat {avContext.sample_fmt}
    
    var threadCount: Int32 {
        
        get {
            pointer.pointee.thread_count
        }
        
        set {
            pointer.pointee.thread_count = newValue
        }
    }
    
    var threadType: Int32 {
        
        get {
            pointer.pointee.thread_type
        }
        
        set {
            pointer.pointee.thread_type = newValue
        }
    }
    
    init(codecPointer: UnsafeMutablePointer<AVCodec>!, codecParams: FFmpegCodecParameters) throws {
        
        self.pointer = avcodec_alloc_context3(codecPointer)
        self.codecID = codecParams.codecID
        
        guard self.pointer != nil else {
            throw CodecInitializationError(description: "Unable to allocate context for codec '\(codecID.name)'")
        }
        
        // Copy the codec's parameters to the codec context.
        let codecCopyResult: ResultCode = avcodec_parameters_to_context(pointer, codecParams.pointer)
        
        guard codecCopyResult.isNonNegative else {
            throw CodecInitializationError(description: "Unable to copy codec parameters to codec context, for codec '\(codecID.name)'. Error: \(codecCopyResult) (\(codecCopyResult.errorDescription)")
        }
    }
    
    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        avcodec_free_context(&pointer)
    }
}
