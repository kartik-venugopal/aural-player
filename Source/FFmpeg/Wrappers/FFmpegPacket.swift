//
//  FFmpegPacket.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates an ffmpeg **AVPacke**t struct that represents a single packet
/// i.e. audio data in its encoded / compressed form, prior to decoding,
/// and provides convenient Swift-style access to their functions and member variables.
///
class FFmpegPacket {
    
    ///
    /// The encapsulated AVPacket object.
    ///
    var avPacket: AVPacket
    
    ///
    /// Index of the stream from which this packet was read.
    ///
    var streamIndex: Int32 {avPacket.stream_index}
    
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
    var rawDataPointer: UnsafeMutablePointer<UInt8>! {avPacket.data}
    
    ///
    /// The raw data encapsulated in a byte buffer, if there is any raw data. Nil if there is no raw data.
    ///
    private(set) lazy var data: Data? = {
        
        if let theData = rawDataPointer, size > 0 {
            return Data(bytes: theData, count: Int(size))
        }
        
        return nil
    }()
    
    ///
    /// Instantiates a Packet from a format context (container), if it can be read. Returns nil otherwise.
    ///
    /// - Parameter formatCtx: The format context (container) from which to read a packet.
    ///
    /// - throws: **PacketReadError** if the read fails.
    ///
    init(readingFromFormat formatCtx: UnsafeMutablePointer<AVFormatContext>?) throws {
        
        self.avPacket = AVPacket()
        
        // Try to read a packet.
        let readResult: Int32 = av_read_frame(formatCtx, &avPacket)
        
        // If the read fails, log a message and throw an error.
        guard readResult >= 0 else {
            
            // No need to log a message for EOF as it is considered harmless.
            if !isEOF(code: readResult) {
                NSLog("Unable to read packet. Error: \(readResult) (\(readResult.errorDescription)))")
            }
            
            throw PacketReadError(readResult)
        }
    }
    
    ///
    /// Instantiates a Packet from an AVPacket that has already been read from the source stream.
    ///
    /// - Parameter pointer: A pointer to a pre-existing AVPacket that has already been read.
    ///
    init(encapsulating pointer: UnsafeMutablePointer<AVPacket>) {
        
        self.avPacket = pointer.pointee
        
        // Since this avPacket was not allocated by this object, we
        // cannot deallocate it here. It is the caller's responsibility
        // to ensure that avPacket is destroyed.
        //
        // So, set the destroyed flag, to prevent deallocation.
        destroyed = true
    }
    
    func sendToCodec(withContext contextPointer: UnsafeMutablePointer<AVCodecContext>!) -> ResultCode {
        avcodec_send_packet(contextPointer, &avPacket)
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
        
        av_packet_unref(&avPacket)
        av_freep(&avPacket)
        
        destroyed = true
    }
    
    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        destroy()
    }
}
