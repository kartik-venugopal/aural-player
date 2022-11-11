//
//  FFmpegPacketTable.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A utility that reads and stores position / timestamp information
/// for every single packet in an audio stream.
///
/// It provides 2 important properties:
///
/// 1 - Duration of the audio stream.
/// 2 - The byte position and presentation timestamp of each packet,
/// which allows efficient arbitrary seeking.
///
/// Typically, this should be necessary only for files with raw audio streams
/// (e.g. aac, dts, ac3) that have either been extracted (demuxed) from, or not
/// been muxed into, a container format such as m4a, mka, etc.
///
/// NOTE - As it is computationally expensive, this method of duration
/// computation should be used as the last resort when all other methods
/// of estimating the duration have failed.
///
class FFmpegPacketTable {
    
    var duration: Double = 0
    private var timeBase: AVRational = AVRational()
    private var packetTable: [FFmpegPacketTableEntry] = []
    
    ///
    /// Attempts to instantiate and build a new PacketTable instance for the given file. May be nil.
    ///
    /// - Parameter file: The audio file for which a packet table is to be built.
    ///
    /// # Notes #
    ///
    /// Will be nil if an error occurs while opening the file and/or reading its packets.
    ///
    init?(for fileContext: FFmpegFileContext) {
        
        guard let stream = fileContext.bestAudioStream else {return nil}
        self.timeBase = stream.timeBase
        
        var lastPacket: FFmpegPacket!
        
        do {
            
            // Keep reading packets till EOF is encountered.
            
            while true {
                
                let packet = try FFmpegPacket(readingFromFormat: fileContext.pointer)
                
                if packet.streamIndex == stream.index {
                    
                    // Store a reference to this packet as the last packet encountered so far.
                    lastPacket = packet
                    
                    // Store byte position and timestamp info for this packet.
                    packetTable.append(FFmpegPacketTableEntry(bytePosition: packet.bytePosition, pts: packet.pts))
                }
            }
            
        } catch {
            
            // If we've reached EOF, we can now compute the stream's duration by converting
            // from stream time units to seconds as follows:
            
            if (error as? PacketReadError)?.isEOF ?? false, let theLastPacket = lastPacket {
                
                self.duration = Double(theLastPacket.pts + theLastPacket.duration) * timeBase.ratio
                
            } else {
                
                // This indicates a real error. Packet table is incomplete.
                return nil
            }
        }
    }
    
    ///
    /// Computes and returns the byte position of the packet in the represented audio stream that is
    /// nearest the given seek position (specified in seconds), by searching the previously built
    /// packet table.
    ///
    /// - Parameter time: A desired seek position, specified in seconds.
    ///
    /// - returns: The byte position of the packet nearest the given seek position.
    ///
    /// # Notes #
    ///
    /// 1. Packet PTS (presentation timestamp) is the criteria used to determine "proximity" to a given seek position.
    ///
    /// 2. This function is intended to be called when performing seeking within a stream with no duration / frame count
    /// information.
    ///
    func closestPacketBytePosition(for time: Double) -> Int64 {
        
        // Convert the given time in seconds to the stream's time base.
        // This will be used as a PTS.
        let targetPTS = Int64(time / timeBase.ratio)
        
        // Search the packet table to find the closest packet by PTS.
        // Clamp it to ensure it is within the bounds of our packet table.
        var targetPacketIndex = indexOfClosestPacket(havingPTS: targetPTS)
        targetPacketIndex.clamp(minValue: 0, maxValue: packetTable.count - 1)
        
        // Return the byte position of our target packet.
        return packetTable[targetPacketIndex].bytePosition
    }
    
    ///
    /// Searches the packet table to find the index of the packet nearest the given PTS.
    ///
    /// - Parameter targetPTS: A PTS to be used as a target value for the search.
    ///
    /// - returns: The index of the packet targeted by the search, i.e. the search result.
    ///
    private func indexOfClosestPacket(havingPTS targetPTS: Int64) -> Int {
        
        // Binary search algorithm (ok to assume that packets are sorted in ascending order by PTS).
        
        var first = 0
        var last = packetTable.count - 1
        
        var center = (first + last) / 2
        var centerPacket = packetTable[center]
        
        while first <= last {
            
            if targetPTS == centerPacket.pts  {
                
                // Found a matching packet
                return center
                
            } else if targetPTS < centerPacket.pts {

                // Narrow the search scope to the half to the left of the center packet.
                last = center - 1
                
            } else if targetPTS > centerPacket.pts {
                
                // Narrow the search scope to the half to the right of the center packet.
                first = center + 1
            }
            
            center = (first + last) / 2
            centerPacket = packetTable[center]
        }
        
        // If no exactly matching packet was found for the target PTS, return the one deemed closest.
        
        if targetPTS < centerPacket.pts {
            
            // Ensure we don't go out of bounds.
            if center == 0 {return 0}
            
            let previousPacket = packetTable[center - 1]
            
            // Compare the center packet's PTS to that of the previous packet.
            // The one whose PTS is closest to the target PTS is the winner.
            
            let centerPacketPTSDiff = abs(centerPacket.pts - targetPTS)
            let previousPacketPTSDiff = abs(previousPacket.pts - targetPTS)
            
            return centerPacketPTSDiff < previousPacketPTSDiff ? center : center - 1
            
        } else {
            
            // targetPTS > centerPacket.pts
            
            // Ensure we don't go out of bounds.
            if center == packetTable.count - 1 {return center}
            
            let nextPacket = packetTable[center + 1]
            
            // Compare the center packet's PTS to that of the next packet.
            // The one whose PTS is closest to the target PTS is the winner.
            
            let centerPacketPTSDiff = abs(centerPacket.pts - targetPTS)
            let nextPacketPTSDiff = abs(nextPacket.pts - targetPTS)
            
            return centerPacketPTSDiff < nextPacketPTSDiff ? center : center + 1
        }
    }
}

///
/// Holds a single packet table entry, i.e. information for a single packet.
///
fileprivate struct FFmpegPacketTableEntry {
   
    ///
    /// Offset position of the packet, in bytes, from the start of the stream.
    ///
    let bytePosition: Int64
    
    ///
    /// PTS (presentation timestamp) of the packet, specified in the stream's time base.
    ///
    let pts: Int64
}
