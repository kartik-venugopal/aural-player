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

struct CLICommand {
    
    let type: CommandType
    let arguments: [String]
    
    static func parse(_ commandString: String) throws -> CLICommand {
        
        if !(commandString.starts(with: "--") && commandString.count >= 3) {
            throw CommandParserError(description: "Malformed command string: Must begin with '--' and be at least 3 total characters long.")
        }
        
        let tokens = commandString.split(separator: " ")
        var cmd = String(tokens[0])
        cmd = cmd.substring(range: 2..<cmd.count)
        
        var args: [String] = []
        
        if tokens.count > 1 {
            args = tokens[1..<tokens.count].map {String($0)}
        }
        
        guard let cmdType = CommandType(rawValue: cmd) else {
            throw CommandParserError(description: "Unrecognized command: '\(cmd)'.")
        }
        
        print("\nCommand is: '\(cmd)', args are: \(args)")
        
        return CLICommand(type: cmdType, arguments: args)
    }
}
