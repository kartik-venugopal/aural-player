//
//  FFmpegCodecContext.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var channelLayout: AVChannelLayout {avContext.ch_layout}
    
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
    
    init(codecPointer: UnsafePointer<AVCodec>!, codecParams: FFmpegCodecParameters) throws {
        
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
    
    func sendPacket(_ packet: FFmpegPacket) -> ResultCode {
        avcodec_send_packet(pointer, &packet.avPacket)
    }
    
    func sendFlushPacket() -> ResultCode {
        avcodec_send_packet(pointer, nil)
    }
    
    ///
    /// Instantiates a Frame, reading an AVFrame from this codec context, and sets its sample format.
    ///
    func receiveFrame() -> FFmpegFrame? {
        
        // Allocate memory for the frame.
        var framePtr: UnsafeMutablePointer<AVFrame>! = av_frame_alloc()
        
        // Check if memory allocation was successful. Can't proceed otherwise.
        guard framePtr != nil else {
            
            NSLog("Unable to allocate memory for frame.")
            return nil
        }
        
        // Receive the frame from the codec context.
        guard avcodec_receive_frame(pointer, framePtr).isNonNegative else {
            
            av_frame_free(&framePtr)
            return nil
        }
        
        return FFmpegFrame(encapsulatingPointeeOf: framePtr, withSampleFormat: FFmpegSampleFormat(encapsulating: self.sampleFormat))
    }

    ///
    /// Decode the current packet and drop (ignore) the received frames.
    ///
    func receiveAndDropAllFrames() {
        
        var avFrame: AVFrame = AVFrame()
        var resultCode: ResultCode = 0
        
        repeat {
            resultCode = avcodec_receive_frame(pointer, &avFrame)
        } while resultCode.isZero && avFrame.nb_samples > 0
    }
    
    ///
    /// Flush this codec's internal buffers.
    ///
    /// Make sure to call this function prior to seeking within a stream.
    ///
    func flushBuffers() {
        avcodec_flush_buffers(pointer)
    }
    
    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        avcodec_free_context(&pointer)
    }
}
