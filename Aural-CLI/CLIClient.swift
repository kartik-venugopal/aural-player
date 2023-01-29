//
//  CLIClient.swift
//  Aural-CLI
//
//  Created by Kartik Venugopal on 25/01/23.
//

import Foundation

class CLIClient {
    
    let msgPort: CFMessagePort
    
    init?(port: String) {
        
        guard let msgPort = CFMessagePortCreateRemote(nil, port as CFString) else {
            
            print("\nFailed to connect to Aural application. Is it running and does the running version accept CLI commands ?")
            return nil
        }
        
        self.msgPort = msgPort
    }
    
    func sendCommand(_ command: String) {
        
        var responseData: Unmanaged<CFData>? = nil
        
        let status = CFMessagePortSendRequest(msgPort, 0,
                                              Data(command.utf8) as CFData,
                                              3.0, 3.0,
                                              CFRunLoopMode.defaultMode.rawValue,
                                              &responseData)
        
        guard status == kCFMessagePortSuccess,
              let responseString = responseData?.retainedString else {
                  
                  // TODO: Throw some error
                  print("\nCommunication Failure !")
                  return
              }
        
        print(responseString)
    }
}

extension Unmanaged where Instance : CFData {
    
    var retainedString: String? {
        
        let retVal = takeRetainedValue()
        guard let data = retVal as! Data?,
              let string = String(data: data, encoding: .utf8) else {
                  return nil
              }
        
        return string
    }
}
