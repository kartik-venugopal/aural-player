//
//  main.swift
//  Aural-CLI
//
//  Created by Kartik Venugopal on 24/01/23.
//

import Cocoa

let runningApps = NSWorkspace.shared.runningApplications

if !runningApps.contains(where: {$0.localizedName == "Aural"}) {
    
    print("Launching app ...")
    launchApp()
    print("Waiting 2 seconds for app to launch, before running command(s) ...")
    sleep(2)
}

processCommands()

func processCommands() {
    
    guard let client: CLIClient = CLIClient(port: "com.kv.Aural") else {
        exit(1)
    }
    
    // Remove the process name (arg 0).
    var args = CommandLine.arguments
    args.removeFirst()
    
    let command: String = args.joined(separator: "\n")
    client.sendCommand(command)
}

func launchApp() {
    
    let rootDir = URL(fileURLWithPath: "/")
    let userDir = FileManager.default.homeDirectoryForCurrentUser
    
    for parentDir in [rootDir, userDir] {
        
        let appURL = parentDir.appendingPathComponent("Applications").appendingPathComponent("Aural.app")
        
        if appURL.exists {
            
            NSWorkspace.shared.open(appURL)
            return
        }
    }
}

extension URL {
    
    static let ascendingPathComparator: (URL, URL) -> Bool = {$0.path < $1.path}
    
    private static let fileManager: FileManager = .default
    
    private var fileManager: FileManager {Self.fileManager}
    
    var lowerCasedExtension: String {
        pathExtension.lowercased()
    }
    
    // Checks if a file exists
    var exists: Bool {
        fileManager.fileExists(atPath: self.path)
    }
    
    var parentDir: URL {
        self.deletingLastPathComponent()
    }
    
    // Checks if a file exists
    static func exists(path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }
    
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    // Computes the size of a file, and returns a convenient representation
    var sizeBytes: UInt64 {
        
        do {
            
            let attr = try fileManager.attributesOfItem(atPath: path)
            return attr[.size] as? UInt64 ?? 0
            
        } catch let error as NSError {
            NSLog("Error getting size of file '%@': %@", path, error.description)
        }
        
        return .zero
    }
    
    func createDirectory() {
        
        if exists {return}
        
        do {
            try fileManager.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory '%@' \(error.debugDescription)", self.path)
        }
    }
    
    // Retrieves the contents of a directory
    var children: [URL]? {
        
        guard exists, isDirectory else {return nil}
        
        do {
            // Retrieve all files/subfolders within this folder
            return try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: [],
                                                                 options: FileManager.DirectoryEnumerationOptions())
            
        } catch let error as NSError {
            
            NSLog("Error retrieving contents of directory '%@': %@", self.path, error.description)
            return nil
        }
    }
    
    // Deletes a file / directory recursively (i.e. all children will be deleted, if it is a directory).
    func delete(recursive: Bool = true) {
        
        guard exists else {return}
        
        do {
            
            if recursive {
                
                // First delete this file's children (if any).
                for file in self.children ?? [] {
                    try fileManager.removeItem(atPath: file.path)
                }
            }
            
            // Delete this file.
            try fileManager.removeItem(atPath: self.path)
            
        } catch let error as NSError {
            NSLog("Error deleting file '%@': %@", self.path, error.description)
        }
    }
    
    // Renames this file
    func rename(to target: URL) {
        
        do {
            try fileManager.moveItem(at: self, to: target)
        } catch let error as NSError {
            NSLog("Error renaming file '%@' to '%@': %@", self.path, target.path, error.description)
        }
    }
    
    // Opens a Finder window, with the given file selected within it
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([self])
    }
}
