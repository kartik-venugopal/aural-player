//
//  main.swift
//  Aural-CLI
//
//  Created by Kartik Venugopal on 24/01/23.
//

import Cocoa

extension NSApplication {
    
    ///
    /// The version number of this application.
    ///
    var appVersion: String {Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String}
}

//var apps = NSWorkspace.shared.runningApplications

guard let msgPort = CFMessagePortCreateRemote(nil, "com.kv.Aural" as CFString) else {

    print("\nFailed to connect to Aural application. Is it running and does it support CLI commands ?")
    exit(1)
}

var unmanagedData: Unmanaged<CFData>? = nil


let status = CFMessagePortSendRequest(msgPort, 0, Data("--playURLs /Users/kven/Music/Grimes \"/Users/kven/Music/Conjure One\"".utf8) as CFData, 3.0, 3.0, CFRunLoopMode.defaultMode.rawValue, &unmanagedData)
let cfData = unmanagedData?.takeRetainedValue()

if status == kCFMessagePortSuccess,
   let data = cfData as Data?,
   let string = String(data: data, encoding: .utf8) {
    
    if string == "success" {
        print("Success !")
    } else {
        print("FAILURE: \(string)")
    }
    
} else {
    print("\nFAILURE !")
}
