//
//  FFmpegCodec.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates an ffmpeg **AVCodec**, **AVCodecContext**, and **AVCodecParameters** struct,
/// and provides convenient Swift-style access to their functions and member variables.
///
class FFmpegCodec {
    
    ///
    /// A pointer to the encapsulated AVCodec object.
    ///
    var pointer: UnsafeMutablePointer<AVCodec>!
    
    ///
    /// The encapsulated AVCodec object.
    ///
    var avCodec: AVCodec {pointer.pointee}
    
    ///
    /// A pointer to a context for the encapsulated AVCodec object.
    ///
    var contextPointer: UnsafeMutablePointer<AVCodecContext>!
    
    ///
    /// A context for the encapsulated AVCodec object.
    ///
    var context: AVCodecContext {contextPointer!.pointee}
    
    ///
    /// A pointer to parameters for the encapsulated AVCodec object.
    ///
    var paramsPointer: UnsafeMutablePointer<AVCodecParameters>
    
    ///
    /// Parameters for the encapsulated AVCodec object.
    ///
    var params: AVCodecParameters {paramsPointer.pointee}
    
    ///
    /// The unique identifier of the encapsulated AVCodec object.
    ///
    var id: UInt32 {avCodec.id.rawValue}
    
    ///
    /// The name of the encapsulated AVCodec object.
    ///
    var name: String {String(cString: avCodec.name)}
    
    ///
    /// The long name of the encapsulated AVCodec object.
    ///
    var longName: String {String(cString: avCodec.long_name)}
    
    var isOpen: Bool = false
    
    ///
    /// Instantiates a Codec object, given a pointer to its parameters.
    ///
    /// - Parameter paramsPointer: A pointer to parameters for the associated AVCodec object.
    ///
    init(fromParameters paramsPointer: UnsafeMutablePointer<AVCodecParameters>) throws {
        
        self.paramsPointer = paramsPointer
        
        // Find the codec by ID.
        let codecID = paramsPointer.pointee.codec_id
        
        self.pointer = avcodec_find_decoder(codecID)
        
        guard self.pointer != nil else {
            throw CodecInitializationError(description: "Unable to find required codec '\(String(cString: avcodec_get_name(codecID)))'")
        }
        
        // Allocate a context for the codec.
        self.contextPointer = avcodec_alloc_context3(pointer)
        
        guard self.contextPointer != nil else {
            throw CodecInitializationError(description: "Unable to allocate context for codec '\(String(cString: avcodec_get_name(codecID)))'")
        }
        
        // Copy the codec's parameters to the codec context.
        let codecCopyResult: ResultCode = avcodec_parameters_to_context(contextPointer, paramsPointer)
        
        guard codecCopyResult.isNonNegative else {
            throw CodecInitializationError(description: "Unable to copy codec parameters to codec context, for codec '\(String(cString: avcodec_get_name(codecID)))'. Error: \(codecCopyResult) (\(codecCopyResult.errorDescription)")
        }
    }
    
    ///
    /// Opens the codec for decoding.
    ///
    /// - throws: **DecoderInitializationError** if the codec cannot be opened.
    ///
    func open() throws {
        
        let codecOpenResult: ResultCode = avcodec_open2(contextPointer, pointer, nil)
        if codecOpenResult.isNonZero {
            
            NSLog("Failed to open codec '\(name)'. Error: \(codecOpenResult.errorDescription))")
            throw DecoderInitializationError(codecOpenResult)
        }
        
        isOpen = true
    }
    
    /// Indicates whether or not this object has already been destroyed.
    private var destroyed: Bool = false
    
    ///
    /// Performs cleanup (deallocation of allocated memory space) when
    /// this object is about to be deinitialized or is no longer needed.
    ///
    func destroy() {

        // This check ensures that the deallocation happens
        // only once. Otherwise, a fatal error will be
        // thrown.
        if destroyed {return}
        
        avcodec_free_context(&contextPointer)

        destroyed = true
    }

    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        destroy()
    }
}
