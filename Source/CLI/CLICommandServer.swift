//
//  CLICommandServer.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

fileprivate let successMessage: CFData = CFData.fromString("Success!")

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
            
            if let responseString = try server.receive(string) {
                return Unmanaged.passRetained(CFData.fromString(responseString))
            }
            
            return Unmanaged.passRetained(successMessage)
            
        } catch let error as CommandParserError {
            return Unmanaged.passRetained(CFData.fromString("Error parsing command: \(error.description)"))
            
        } catch let error as CommandProcessorError {
            return Unmanaged.passRetained(CFData.fromString("Error processing command: \(error.description)"))
            
        } catch {
            return Unmanaged.passRetained(CFData.fromString("Unknown error"))
        }
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
    
    func receive(_ commandString: String) throws -> String? {
        
        print("\nReceived command string:\n\(commandString)\n")
        
        let commands = try CLICommand.parse(commandString)
        return try commandProcessor.process(commands)
    }
}

extension CFData {
    
    static func fromString(_ string: String) -> CFData {
        Data(string.utf8) as CFData
    }
}
