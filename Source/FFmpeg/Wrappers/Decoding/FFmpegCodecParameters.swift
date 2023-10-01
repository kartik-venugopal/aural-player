//
//  FFmpegCodecParameters.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FFmpegCodecParameters {
    
    ///
    /// A pointer to parameters for the encapsulated AVCodec object.
    ///
    let pointer: UnsafeMutablePointer<AVCodecParameters>
    
    ///
    /// Parameters for the encapsulated AVCodec object.
    ///
    var avParams: AVCodecParameters {pointer.pointee}
    
    var codecID: AVCodecID {avParams.codec_id}
    
    ///
    /// Average bit rate of the encoded data.
    ///
    var bitRate: Int64 {avParams.bit_rate}
    
    ///
    /// Sample rate of the encoded data (i.e. number of samples per second or Hz).
    ///
    var sampleRate: Int32 {avParams.sample_rate}
    
    var channels: Int32 {avParams.channels}
    
    init(pointer: UnsafeMutablePointer<AVCodecParameters>) {
        self.pointer = pointer
    }
}
