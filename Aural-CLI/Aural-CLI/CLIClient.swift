//
//  CLIClient.swift
//  Aural-CLI
//
//  Created by Kartik Venugopal on 25/01/23.
//

import Foundation

class CLIClient {
    
    var msgPort: CFMessagePort!
    
    init?(port: String) {
        
        guard let msgPort = CFMessagePortCreateRemote(nil, port as CFString) else {
            
            print("\nFailed to connect to Aural application. Is it running and does the running version support CLI commands ?")
            return nil
        }
        
        //var apps = NSWorkspace.shared.runningApplications
        
        self.msgPort = msgPort
    }
    
    func sendCommand(_ command: String) {
        
        var unmanagedData: Unmanaged<CFData>? = nil
        
        let status = CFMessagePortSendRequest(msgPort, 0,
                                              Data(command.utf8) as CFData,
                                              3.0, 3.0,
                                              CFRunLoopMode.defaultMode.rawValue,
                                              &unmanagedData)
        
        let cfData = unmanagedData?.takeRetainedValue()
        
        guard status == kCFMessagePortSuccess,
              let data = cfData as Data?,
              let string = String(data: data, encoding: .utf8) else {
                  
                  // TODO: Throw some error
                  
                  print("\nCommunication Failure !")
                  return
              }
        
        if string == "success" {
            print("Success !")
        } else {
            print("FAILURE: \(string)")
        }
    }
}
