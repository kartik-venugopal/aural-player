//
//  FFmpegCoverArtReader.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Encapsulates an ffmpeg **AVFormatContext** struct that represents an audio file's container format,
/// and provides convenient Swift-style access to its functions and member variables.
///
/// - Demultiplexing: Reads all streams within the audio file.
/// - Reads and provides audio stream data as encoded / compressed packets (which can be passed to the appropriate codec).
/// - Performs seeking to arbitrary positions within the audio stream.
///
class FFmpegCoverArtReader {

    ///
    /// Attempts to construct a FormatContext instance for the given file.
    ///
    /// - Parameter file: The audio file to be read / decoded by this context.
    ///
    /// Fails (returns nil) if:
    ///
    /// - An error occurs while opening the file or reading (demuxing) its streams.
    /// - No audio stream is found in the file.
    ///
    static func readCoverArt(from file: URL) throws -> Data? {
        
        // MARK: Open the file ----------------------------------------------------------------------------------
        
        // Allocate memory for this format context.
        var pointer: UnsafeMutablePointer<AVFormatContext>? = avformat_alloc_context()
        
        guard let thePointer = pointer else {
            throw FormatContextInitializationError(description: "Unable to allocate memory for format context for file '\(file.path)'.")
        }
        
        defer {
            
            // Close the context.
            avformat_close_input(&pointer)
            
            // Free the context and all its streams.
            avformat_free_context(pointer)
        }
        
        // Try to open the audio file so that it can be read.
        var resultCode: ResultCode = avformat_open_input(&pointer, file.path, nil, nil)
        
        // If the file open failed, log a message and return nil.
        guard resultCode.isNonNegative else {
            throw FormatContextInitializationError(description: "Unable to open file '\(file.path)'. Error: \(resultCode.errorDescription)")
        }
        
        // MARK: Read the streams ----------------------------------------------------------------------------------
        
        // Try to read information about the streams contained in this file.
        resultCode = avformat_find_stream_info(pointer, nil)
        
        // If the read failed, log a message and return nil.
        guard resultCode.isNonNegative, let avStreamsArrayPointer = thePointer.pointee.streams else {
            throw FormatContextInitializationError(description: "Unable to find stream info for file '\(file.path)'. Error: \(resultCode.errorDescription)")
        }
        
        let streamIndex = av_find_best_stream(pointer, AVMEDIA_TYPE_VIDEO, -1, -1, nil, 0)
        guard streamIndex.isNonNegative, let stream = avStreamsArrayPointer.advanced(by: Int(streamIndex)).pointee else {return nil}
        
        // MARK: Read the attached pic packet data ----------------------------------------------------------------------------------
        
        let packet = stream.pointee.attached_pic
        guard let theData = packet.data, packet.size > 0 else {return nil}

        return Data(bytes: theData, count: Int(packet.size))
    }
}
