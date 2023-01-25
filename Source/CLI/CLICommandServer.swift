//
//  CLICommandServer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

enum CommandType: String, CaseIterable, Codable {
    
    case playURLs, enqueueURLs, volume, mute, unmute, `repeat`, shuffle, stop, nextTrack, previousTrack, skipForward, skipBackward
}

class CommandParserError: Error {
    
    let description: String
    
    init(description: String) {
        self.description = description
    }
}

fileprivate let successMessage: CFData = Data("success".utf8) as CFData

extension CFData {
    
    static func fromString(_ string: String) -> CFData {
        Data(string.utf8) as CFData
    }
}

class CLICommandServer {

    static let portName: CFString = Bundle.main.bundleIdentifier! as CFString
    private let commandProcessor: CLICommandProcessor = objectGraph.cliCommandProcessor
    
    var messagePort: CFMessagePort! = nil
  
    lazy var callback: CFMessagePortCallBack = {msgPort, msgID, cfData, info in
        
        guard let serverPtr = info,
              let dataReceived = cfData as Data?,
              let string = String(data: dataReceived, encoding: .utf8) else {
                  return nil
              }
        
        let server = Unmanaged<CLICommandServer>.fromOpaque(serverPtr).takeUnretainedValue()
        
        do {
            try server.receive(string)
            
        } catch let error as CommandParserError {
            return Unmanaged.passRetained(CFData.fromString("error-\(error.description)"))
            
        } catch {
            
            print("\nUNKNOWN ERROR !")
            return Unmanaged.passRetained(CFData.fromString("error-unknown"))
        }
        
        return Unmanaged.passRetained(successMessage)
    }
    
    func start() {
        
        let info = Unmanaged.passUnretained(self).toOpaque()
        var ctx: CFMessagePortContext = .init(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
        
        if let msgPort = CFMessagePortCreateLocal(nil, Self.portName, callback, &ctx, nil),
            let source = CFMessagePortCreateRunLoopSource(nil, msgPort, 0) {
            
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
            print("\nStarted Command Server for: \(Self.portName)")
            self.messagePort = msgPort
        }
    }
    
    func stop() {
        
        if let port = self.messagePort {
            
            CFMessagePortInvalidate(port)
            self.messagePort = nil
            print("\nStopped Command Server.")
        }
    }
    
    func receive(_ commandString: String) throws {
        
        let command = try CLICommand.parse(commandString)
        try commandProcessor.process(command)
    }
}
