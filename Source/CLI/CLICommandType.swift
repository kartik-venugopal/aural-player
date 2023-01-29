//
//  CLICommandType.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

enum CLICommandType: String, CaseIterable {
    
    case listCommands,
         playURLs,
         enqueueURLs,
         volume,
         mute,
         unmute,
         `repeat`,
         shuffle,
         togglePlayPause,
         stop,
         replayTrack,
         previousTrack,
         nextTrack,
         skipBackward,
         skipForward,
         jumpToTime,
         pitchShift,
         timeStretch,
         uiMode
//         runScript
    
    var description: String {
        
        switch self {
            
        case .listCommands:
            
            return "Lists all the CLI commands that this instance of Aural can process."
            
        case .playURLs:
            
            return "Plays the given files / folders / M3U playlists, replacing anything in the current Aural playlist."
            
        case .enqueueURLs:
            
            return "Enqueues / appends the given files / folders / M3U playlists to the end of the current Aural playlist."
            
        case .volume:
            
            return "Sets the volume."
            
        case .mute:
            
            return "Mutes the player."
            
        case .unmute:
            
            return "Un-mutes the player."
            
        case .`repeat`:
            
            return "Sets the repeat mode."
            
        case .shuffle:
            
            return "Sets the shuffle mode."
            
        case .togglePlayPause:
            
            return "Toggles playback state between play/pause."
            
        case .stop:
            
            return "Stops playback."
            
        case .replayTrack:
            
            return "Restarts playback of the current track (if there is one) from the zero position."
            
        case .previousTrack:
            
            return "Skips to the previous track in the playlist."
            
        case .nextTrack:
            
            return "Skips to the next track in the playlist."
            
        case .skipBackward:
            
            return "Skips playback backwards within the current track (if there is one)."
            
        case .skipForward:
            
            return "Skips playback forwards within the current track (if there is one)."
            
        case .jumpToTime:
            
            return "Jumps to a specific playback position within the current track (if there is one)."
            
        case .pitchShift:
            
            return "Adjusts the Pitch Shift effect."
            
        case .timeStretch:
            
            return "Adjusts the Time Stretch effect."
            
        case .uiMode:
            
            return "Sets the application's UI presentation mode."
            
//        case .runScript:
//
//            return "Runs a script of commands."
        }
    }
    
    var args: String {
        
        switch self {
            
        case .listCommands, .mute, .unmute, .togglePlayPause, .stop, .replayTrack, .previousTrack, .nextTrack:
            
            return "<None>"
            
        case .playURLs:
            
            return "1 or more file / folder / M3U playlist URLs (URLs with spaces must be enclosed in quotes)."
            
        case .enqueueURLs:
            
            return "1 or more file / folder / M3U playlist URLs (URLs with spaces must be enclosed in quotes)."
            
        case .volume:
            
            return "1 floating-point number between 0 and 100"
            
        case .`repeat`:
            
            return "off | one | all"
            
        case .shuffle:
            
            return "off | on"
            
        case .skipBackward:
            
            return "(Optional) 1 floating-point number representing the number of seconds to skip (will default to app preference)."
            
        case .skipForward:
            
            return "(Optional) 1 floating-point number representing the number of seconds to skip (will default to app preference)."
            
        case .jumpToTime:
            
            return "The desired playback position formatted as hh:mm:ss"
            
        case .pitchShift:
            
            return "1 floating-point number between -2400 and 2400"
            
        case .timeStretch:
            
            return "1 floating-point number between 0.25 and 4.0"
            
        case .uiMode:
            
            return "windowed | menuBar | controlBar"
            
//        case .runScript:
//
//            return "The URL of a text file containing the script to be run."
        }
    }
}
