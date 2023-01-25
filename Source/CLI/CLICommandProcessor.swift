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
    
    func process(_ command: CLICommand) throws {
        
        switch command.type {
            
        case .playURLs:
            
            guard command.arguments.count >= 1 else {
                throw CommandProcessorError(description: "At least one file/folder path must be specified for --playURLs.")
            }
            
            let urls = command.arguments.map {URL(fileURLWithPath: $0)}
            messenger.publish(.player_playFiles, payload: urls)

        case .mute:

            messenger.publish(.player_mute)
            
        case .unmute:

            messenger.publish(.player_unmute)
            
        case .volume:
            
            guard command.arguments.count == 1,
                  let volumeFloat = Float(command.arguments[0]),
                  volumeFloat >= 0, volumeFloat <= 100.0 else {
                      
                      throw CommandProcessorError(description: "Exactly one floating point argument between 0 and 100 must be specified for --volume.")
                  }
            
            messenger.publish(.player_setVolume, payload: volumeFloat)
            
        case .stop:
            
            messenger.publish(.player_stop)

        default:
            
            return
        }
    }
}
