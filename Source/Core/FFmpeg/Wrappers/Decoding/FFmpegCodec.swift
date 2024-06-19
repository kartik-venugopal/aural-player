//
//  FFmpegCodec.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    /// A context for the encapsulated AVCodec object.
    ///
    let context: FFmpegCodecContext
    
    ///
    /// Decoding parameters for the encapsulated AVCodec object.
    ///
    let params: FFmpegCodecParameters
    
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
        
        self.params = .init(pointer: paramsPointer)
        self.pointer = try Self.findDecoder(fromParams: params)
        
        // Allocate a context for the codec.
        self.context = try .init(codecPointer: pointer, codecParams: params)
    }
    
    static func findDecoder(fromParams params: FFmpegCodecParameters) throws -> UnsafeMutablePointer<AVCodec> {
        
        let codecID = params.codecID
        
        guard let pointer = avcodec_find_decoder(codecID) else {
            throw CodecInitializationError(description: "Unable to find required codec '\(codecID.name)'")
        }
        
        return pointer
    }
    
    ///
    /// Opens the codec for decoding.
    ///
    /// - throws: **DecoderInitializationError** if the codec cannot be opened.
    ///
    func open() throws {
        
        let codecOpenResult: ResultCode = avcodec_open2(context.pointer, pointer, nil)
        if codecOpenResult.isNonZero {
            
            NSLog("Failed to open codec '\(name)'. Error: \(codecOpenResult.errorDescription))")
            throw DecoderInitializationError(codecOpenResult)
        }
        
        isOpen = true
    }
}

extension AVCodecID {
    
    var name: String {
        String(cString: avcodec_get_name(self))
    }
}
