//
//  main.swift
//  Aural-CLI
//
//  Created by Kartik Venugopal on 24/01/23.
//

import Cocoa

guard let client: CLIClient = CLIClient(port: "com.kv.Aural") else {
    exit(1)
}

//let command: String = "--playURLs /Users/kven/Music/Grimes \"/Users/kven/Music/Conjure One\""
let command: String = "--timeStretch 1.05"

client.sendCommand(command)
