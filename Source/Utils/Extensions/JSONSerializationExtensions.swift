//
//  JSONSerializationExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension JSONSerialization {
    
    static func writeObject(_ jsonObject: NSDictionary, toFile file: URL, failSilently: Bool = false) throws {
        
        if let outputStream = OutputStream(url: file, append: false) {
            
            outputStream.open()
            
            if !JSONSerialization.isValidJSONObject(jsonObject) {
                
                outputStream.close()
                
                if failSilently {
                    NSLog("Error writing JSON object: Invalid JSON object specified")
                } else {
                    throw JSONWriteError.invalidObject
                }
                
                return
            }
            
            var ioError: NSError?
            let bytesWritten = Self.writeJSONObject(jsonObject, to: outputStream, options: Self.WritingOptions.prettyPrinted, error: &ioError)
            
            outputStream.close()
            
            if let error = ioError {
                
                if failSilently {
                    NSLog("Error writing JSON object to file: %@", error.description)
                } else {
                    throw JSONWriteError(description: error.description)
                }
                
            } else if bytesWritten == 0 {
                
                if failSilently {
                    NSLog("Error writing JSON object to file: No bytes written to the stream")
                } else {
                    throw JSONWriteError.noBytesWritten
                }
            }
            
        } else {
            
            if failSilently {
                NSLog("Error saving app state config file: Unable to create output stream.")
            } else {
                throw JSONWriteError.cantCreateOutputStream
            }
        }
    }
}

class JSONWriteError: DisplayableError {
    
    var description: String
    
    init(description: String) {
        
        self.description = description
        super.init("Error writing JSON object to file")
    }
    
    static let invalidObject: JSONWriteError = JSONWriteError(description: "Invalid JSON object specified")
    static let noBytesWritten: JSONWriteError = JSONWriteError(description: "No bytes written to the stream")
    static let cantCreateOutputStream: JSONWriteError = JSONWriteError(description: "Unable to create output stream")
}
