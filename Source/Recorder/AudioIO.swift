//
//  AudioIO.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

/*
    Performs I/O of audio data.
 */
class AudioIO {
    
    // Utility method for creating an AVAudioFile from a URL, for writing
    static func createAudioFileForWriting(_ url: URL, _ settings: [String: Any]) -> AVAudioFile? {
        
        // Create the output file with the specified format
        do {
            
            return try AVAudioFile(forWriting: url, settings: settings)
            
        } catch let error as NSError {
            
            NSLog("Error creating audio file '%@' for writing: %@", url.path, error.description)
            return nil
        }
    }
    
    // Writes a single buffer of audio data to the specified audio file
    static func writeAudio(_ buffer: AVAudioPCMBuffer, _ audioFile: AVAudioFile) {
        
        do {
            try audioFile.write(from: buffer)
        } catch let error as NSError {
            NSLog("Error writing to audio file '%@' atPos '%d': %@", audioFile.url.path, audioFile.framePosition, error.description)
        }
    }
}
