//
//  FFmpegStreamProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A contract for all **AVStream** wrapper classes.
///
protocol FFmpegStreamProtocol {
    
    ///
    /// The encapsulated AVStream object.
    ///
    var avStream: AVStream {get}
    
    ///
    /// The media type of data contained within this stream (e.g. audio, video, etc)
    ///
    var mediaType: AVMediaType {get}
    
    ///
    /// The index of this stream within its container.
    ///
    var index: Int32 {get}
    
    ///
    /// All metadata key / value pairs available for this stream.
    ///
    var metadata: [String: String] {get}
}

///
/// Convenience functions that are useful when converting between stream time units and seconds (used by the user interface).
///
extension AVRational {

    var ratio: Double {Double(num) / Double(den)}
    
    var reciprocalRatio: Double {Double(den) / Double(num)}
}
