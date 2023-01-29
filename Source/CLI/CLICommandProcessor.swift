//
//  CLICommandProcessor.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class CommandProcessorError: Error {
    
    let description: String
    
    init(description: String) {
        self.description = description
    }
}

class CLICommandProcessor {
    
    static let shared: CLICommandProcessor = .init()
    
    private init() {}
    
    private lazy var messenger: Messenger = .init(for: self)
    
    func process(_ commands: [CLICommand]) throws -> String? {
        
        var output: String? = nil
        
        for command in commands {
            
            switch command.type {
                
            case .listCommands:
                
                var outputStr: String = "\n"
                
                for cmdType in CLICommandType.allCases {
                    outputStr += "\(cmdType.rawValue): \(cmdType.description)\nArguments: \(cmdType.args)\n\n"
                }
                
                output = outputStr
                
            case .playURLs:
                
                guard command.arguments.count >= 1 else {
                    throw CommandProcessorError(description: "At least one file/folder path must be specified for --playURLs.")
                }
                
                let urls = command.arguments.map {URL(fileURLWithPath: $0)}
                messenger.publish(.player_playFiles, payload: urls)
                
            case .enqueueURLs:
                
                guard command.arguments.count >= 1 else {
                    throw CommandProcessorError(description: "At least one file/folder path must be specified for --enqueueURLs.")
                }
                
                let urls = command.arguments.map {URL(fileURLWithPath: $0)}
                messenger.publish(.player_enqueueFiles, payload: urls)
                
            case .volume:
                
                guard command.arguments.count == 1,
                      let volumeFloat = Float(command.arguments[0]),
                      volumeFloat >= 0, volumeFloat <= 100.0 else {
                          
                          throw CommandProcessorError(description: "Exactly one floating-point argument between 0 and 100 must be specified for --volume.")
                      }
                
                messenger.publish(.player_setVolume, payload: volumeFloat)
                
            case .mute:
                
                messenger.publish(.player_mute)
                
            case .unmute:
                
                messenger.publish(.player_unmute)
                
            case .repeat:
                
                guard command.arguments.count == 1, let repeatMode = RepeatMode(rawValue: command.arguments[0]) else {
                    throw CommandProcessorError(description: "Exactly one argument must be specified for --repeat. Specify repeat mode ('off', 'one', 'all')")
                }
                
                messenger.publish(.player_setRepeatMode, payload: repeatMode)
                
            case .shuffle:
                
                guard command.arguments.count == 1, let shuffleMode = ShuffleMode(rawValue: command.arguments[0]) else {
                    throw CommandProcessorError(description: "Exactly one argument must be specified for --shuffle. Specify shuffle mode ('off', 'on')")
                }
                
                messenger.publish(.player_setShuffleMode, payload: shuffleMode)
                
            case .togglePlayback:
                
                messenger.publish(.player_playOrPause)
                
            case .stop:
                
                messenger.publish(.player_stop)
                
            case .replayTrack:
                
                messenger.publish(.player_replayTrack)
                
            case .previousTrack:
                
                messenger.publish(.player_previousTrack)
                
            case .nextTrack:
                
                messenger.publish(.player_nextTrack)
                
            case .skipBackward:
                
                if command.arguments.isNonEmpty {
                    
                    guard command.arguments.count == 1,
                          let interval = Double(command.arguments[0]),
                          interval >= 0 else {
                              
                              throw CommandProcessorError(description: "Exactly one floating-point argument greater than 0 must be specified for --skipBackward.")
                          }
                    
                    messenger.publish(.player_seekBackwardByInterval, payload: interval)
                    
                } else {
                    messenger.publish(.player_seekBackward, payload: UserInputMode.discrete)
                }
                
            case .skipForward:
                
                if command.arguments.isNonEmpty {
                    
                    guard command.arguments.count == 1,
                          let interval = Double(command.arguments[0]),
                          interval >= 0 else {
                              
                              throw CommandProcessorError(description: "Exactly one floating-point argument greater than 0 must be specified for --skipForward.")
                          }
                    
                    messenger.publish(.player_seekForwardByInterval, payload: interval)
                    
                } else {
                    messenger.publish(.player_seekForward, payload: UserInputMode.discrete)
                }
                
            case .jumpToTime:
                
                guard command.arguments.count == 1 else {
                    throw CommandProcessorError(description: "Exactly one formatted time argument (hh:mm:ss) must be specified for --jumpToTime.")
                }
                
                let timeString = command.arguments[0]
                let tokens = timeString.split(separator: ":")
                
                guard tokens.count == 3 else {
                    throw CommandProcessorError(description: "Exactly one formatted time argument (hh:mm:ss) must be specified for --jumpToTime.")
                }
                
                let hoursStr = String(tokens[0])
                let minsStr = String(tokens[1])
                let secsStr = String(tokens[2])
                
                guard let hours = Int(hoursStr),
                      let mins = Int(minsStr),
                      let secs = Double(secsStr) else {
                          
                          throw CommandProcessorError(description: "Exactly one formatted time argument (hh:mm:ss) must be specified for --jumpToTime.")
                      }
                
                let totalSecs: Double = (Double(hours) * 3600.0) + (Double(mins) * 60.0) + secs
                messenger.publish(.player_jumpToTime, payload: totalSecs)
                
            case .pitchShift:
                
                guard command.arguments.count == 1,
                      let pitchFloat = Float(command.arguments[0]),
                      pitchFloat >= -2400, pitchFloat <= 2400 else {
                          
                          throw CommandProcessorError(description: "Exactly one floating-point argument between -2400.0 and 2400.0 must be specified for --pitchShift.")
                      }
                
                messenger.publish(.pitchEffectsUnit_setPitch, payload: pitchFloat)
                
            case .timeStretch:
                
                guard command.arguments.count == 1,
                      let rateFloat = Float(command.arguments[0]),
                      rateFloat >= 0.25, rateFloat <= 4 else {
                          
                          throw CommandProcessorError(description: "Exactly one floating-point argument between 0.25 and 4.0 must be specified for --timeStretch.")
                      }
                
                messenger.publish(.timeEffectsUnit_setRate, payload: rateFloat)
                
            case .uiMode:
                
                guard command.arguments.count == 1,
                      let appMode = AppMode(rawValue: command.arguments[0]) else {
                          
                          throw CommandProcessorError(description: "Exactly one app mode argument (windowed | menuBar | controlBar) must be specified for --uiMode.")
                      }
                
                messenger.publish(.application_switchMode, payload: appMode)
            }
        }
        
        return output
    }
}
