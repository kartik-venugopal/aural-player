//
//  FFmpegPacket.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates an ffmpeg **AVPacket** struct that represents a single packet
/// i.e. audio data in its encoded / compressed form, prior to decoding,
/// and provides convenient Swift-style access to its functions and member variables.
///
class FFmpegPacket {
    
    ///
    /// The encapsulated AVPacket object.
    ///
    var avPacket: AVPacket
    
    ///
    /// Size, in bytes, of this packet's data.
    ///
    var size: Int32 {avPacket.size}
    
    ///
    /// Duration of the packet's samples, specified in the source stream's time base units.
    ///
    var duration: Int64 {avPacket.duration}
    
    ///
    /// Offset position of the packet, in bytes, from the start of the stream.
    ///
    var bytePosition: Int64 {avPacket.pos}
    
    ///
    /// Presentation timestamp (PTS) of this packet, specified in the source stream's time base units.
    ///
    var pts: Int64 {avPacket.pts}
    
    ///
    /// Pointer to the raw data (unsigned bytes) contained in this packet.
    ///
    var rawDataPointer: BytePointer! {avPacket.data}
    
    ///
    /// The raw data encapsulated in a byte buffer, if there is any raw data. Nil if there is no raw data.
    ///
    private(set) lazy var data: Data? = {
        
        if let theData = rawDataPointer, size > 0 {
            return Data(bytes: theData, count: Int(size))
        }
        
        return nil
    }()
    
    /// Indicates whether or not this object needs to free up used memory space.
    private let needToDealloc: Bool
    
    ///
    /// Instantiates a Packet from a format context (container), if it can be read. Returns nil otherwise.
    ///
    /// - Parameter formatCtx: The format context (container) from which to read a packet.
    ///
    /// - throws: **PacketReadError** if the read fails.
    ///
    init(encapsulating packet: AVPacket) {
        
        self.avPacket = packet
        self.needToDealloc = true
    }
    
    ///
    /// Instantiates a Packet from an AVPacket that has already been read from the source stream.
    ///
    /// - Parameter pointer: A pointer to a pre-existing AVPacket that has already been read.
    ///
    init(encapsulatingPointeeOf pointer: UnsafeMutablePointer<AVPacket>) {
        
        self.avPacket = pointer.pointee
        
        // Since this avPacket was not allocated by this object, we
        // cannot deallocate it here. It is the caller's responsibility
        // to ensure that avPacket is destroyed.
        //
        // So, set the needToDealloc flag, to prevent deallocation.
        needToDealloc = false
    }

    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        
        if needToDealloc {
            
            av_packet_unref(&avPacket)
            av_freep(&avPacket)
        }
    }
}
