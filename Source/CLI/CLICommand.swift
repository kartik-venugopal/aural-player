//
//  CLICommand.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

enum CommandType: String, CaseIterable, Codable {
    
    case listCommands, playURLs, enqueueURLs, volume, mute, unmute, `repeat`, shuffle, stop, replayTrack, previousTrack, nextTrack, skipBackward, skipForward, jumpToTime, pitchShift, timeStretch, uiMode, runScript
    
    // TODO: Man page descriptions for each command type (incl. their args and value constraints)
}

struct CLICommand {
    
    let type: CommandType
    let arguments: [String]
    
    static func parse(_ commandString: String) throws -> [CLICommand] {
        
        let tokens = commandString.split(separator: "\n")
        var commands: [CLICommand] = []
        var cur = 0
        
        while cur < tokens.count {
            
            let cmd = String(tokens[cur])
            cur.increment()
            var args: [String] = []
            
            while cur < tokens.count && !tokens[cur].starts(with: "--") {
                args.append(String(tokens[cur]))
                cur.increment()
            }
            
            commands.append(try parseSingleCommand(cmd, args: args))
            NSLog("Received command: '\(cmd)', with args: \(args)")
        }
        
        return commands
    }
    
    private static func parseSingleCommand(_ commandString: String, args: [String]) throws -> CLICommand {
        
        if !(commandString.starts(with: "--") && commandString.count >= 3) {
            throw CommandParserError(description: "Malformed command string: Must begin with '--' and be at least 3 total characters long.")
        }
        
        guard let cmdType = CommandType(rawValue: commandString.substring(range: 2..<commandString.count)) else {
            throw CommandParserError(description: "Unrecognized command: '\(commandString)'.")
        }
        
        return CLICommand(type: cmdType, arguments: args)
    }
}

class CommandParserError: Error {
    
    let description: String
    
    init(description: String) {
        self.description = description
    }
}
