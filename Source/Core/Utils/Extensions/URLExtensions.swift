//
//  URLExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import Cocoa

extension URL {
    
    static let ascendingPathComparator: (URL, URL) -> Bool = {$0.path < $1.path}
    
    private static let fileManager: FileManager = .default
    
    private var fileManager: FileManager {Self.fileManager}
    
    var lowerCasedExtension: String {
        pathExtension.lowercased()
    }
    
    var nameWithoutExtension: String {
        deletingPathExtension().lastPathComponent
    }
    
    var isNativelySupported: Bool {
        SupportedTypes.nativeAudioExtensions.contains(lowerCasedExtension)
    }
    
    var isNonNativelySupported: Bool {
        SupportedTypes.nonNativeAudioExtensions.contains(lowerCasedExtension)
    }
    
    var isSupportedAudioFile: Bool {
        SupportedTypes.allAudioExtensions.contains(lowerCasedExtension)
    }
    
    var isSupportedPlaylistFile: Bool {
        SupportedTypes.playlistExtensions.contains(lowerCasedExtension)
    }
    
    var isSupportedFile: Bool {
        isSupportedAudioFile || isSupportedPlaylistFile
    }
    
    var isSupportedLyricsFile: Bool {
        SupportedTypes.lyricsFileExtensions.contains(lowerCasedExtension)
    }
    
    // Checks if a file exists
    var exists: Bool {
        fileManager.fileExists(atPath: self.path)
    }
    
    var parentDir: URL {
        self.deletingLastPathComponent()
    }
    
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    static func atLeastOneSupportedURL(in urls: [URL]) -> Bool {
        
        for url in urls {
            
            if url.isSupportedFile || url.isDirectory || url.isAliasOrSymLink {
                return true
            }
        }
        
        return false
    }
    
    // Computes the size of a file, and returns a convenient representation
    var size: FileSize {
        
        do {
            
            let attr = try fileManager.attributesOfItem(atPath: path)
            return FileSize(sizeBytes: attr[.size] as? UInt64 ?? 0)
            
        } catch let error as NSError {
            NSLog("Error getting size of file '%@': %@", path, error.description)
        }
        
        return .zero
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
    
    var attributes: FileAttributes {
        
        var fileSize : FileSize?
        var lastModified: Date?
        var creationDate: Date?
        var kindOfFile: String?
        var lastOpened: Date?
        
        if let mditem = MDItemCreate(nil, path as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String: Any] {
            
            kindOfFile = mdattrs[kMDItemKind as String, String.self]
            lastOpened = mdattrs[kMDItemLastUsedDate as String, Date.self]
        }
        
        do {

            let attr = try fileManager.attributesOfItem(atPath: path)
            fileSize = FileSize(sizeBytes: attr.uint64Value(forKey: .size) ?? 0)
            
            if let modDate = attr[.modificationDate, Date.self] {
                lastModified = modDate
            }
            
            if let cDate = attr[.creationDate, Date.self] {
                creationDate = cDate
            }
            
        } catch let error as NSError {
            NSLog("Error getting size of file '%@': %@", path, error.description)
        }
        
        return FileAttributes(size: fileSize, lastModified: lastModified, creationDate: creationDate,
                              kindOfFile: kindOfFile, lastOpened: lastOpened)
    }
    
    var lastModifiedTime: Date? {
        
        do {

            let attr = try fileManager.attributesOfItem(atPath: path)
            return attr[.modificationDate, Date.self]
            
        } catch let error as NSError {
            
            NSLog("Error getting size of file '%@': %@", path, error.description)
            return nil
        }
    }
    
    func createDirectory() {
        
        if exists {return}
        
        do
        {
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
                                                       options: .skipsHiddenFiles)
            
        } catch let error as NSError {
            
            NSLog("Error retrieving contents of directory '%@': %@", self.path, error.description)
            return nil
        }
    }
    
    // Retrieves the files in a directory (skipping subdirectories)
    var childrenFiles: [URL]? {
        
        guard exists, isDirectory else {return nil}
        
        do {
            // Retrieve all files/subfolders within this folder
            return try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: [],
                                                       options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
            
        } catch let error as NSError {
            
            NSLog("Error retrieving contents of directory '%@': %@", self.path, error.description)
            return nil
        }
    }
    
    func findFileWithoutExtensionNamed(_ fileName: String) -> URL? {
        children?.first(where: {$0.nameWithoutExtension == fileName})
    }
    
    // Deletes a file / directory recursively (i.e. all children will be deleted, if it is a directory).
    func delete() {
        
        guard exists else {return}
        
        do {
            // Delete this file.
            try fileManager.removeItem(atPath: self.path)
            
        } catch let error as NSError {
            NSLog("Error deleting file '%@': %@", self.path, error.description)
        }
    }
    
    func moveToTrash() {
        
        guard exists else {return}
        
        do {
            try fileManager.trashItem(at: self, resultingItemURL: nil)
            
        } catch let error as NSError {
            NSLog("Error moving file '%@' to trash: %@", self.path, error.description)
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
    
    // Computes the path of this file relative to a base.
    // For example, if base = /A/B/C/D.m3u, and this file = /A/E.mp3, then the relative path = ../../E.mp3
    func path(relativeTo base: URL) -> String {
        
        let sComps = base.deletingLastPathComponent().resolvingSymlinksInPath().pathComponents
        let tComps = self.deletingLastPathComponent().resolvingSymlinksInPath().pathComponents
        
        // Cursor for traversing the path components
        var cur = 0
        
        // Stays true as long as path components at each level match
        var pathMatch: Bool = true
        
        // Find common path
        // Example: if src = /A/B/C/D, and target = /A/E, then common path = /A
        while cur < sComps.count && cur < tComps.count && pathMatch {
            
            if sComps[cur] != tComps[cur] {
                pathMatch = false
            } else {
                cur.increment()
            }
        }
        
        // Traverse the source path from the end, up to the last common path component, depending on the value of cur
        let upLevels = sComps.count - cur
        var relPath = ""
        
        if (upLevels > 0) {
            for _ in 1...upLevels {
                relPath.append("../")
            }
        }
        
        // Then, traverse down the target path
        if cur < tComps.count {
            
            for i in cur...tComps.count - 1 {
                relPath.append(tComps[i] + "/")
            }
        }
        
        // Finally, append the target file name
        relPath.append(self.lastPathComponent)
        
        return relPath
    }
    
    // Resolves a Finder alias and returns its true file URL
    func resolvingAlias() -> URL {
        
        do {
            // Get information about the file alias.
            // If the file is not an alias files, an exception is thrown
            // and execution continues in the catch clause.
            
            let data = try URL.bookmarkData(withContentsOf: self)
            
            // NSURLPathKey contains the target path.
            let resourceValues = URL.resourceValues(forKeys: [.pathKey], fromBookmarkData: data)
            
            if let targetPath = resourceValues?.allValues[.pathKey, String.self] {
                return URL(fileURLWithPath: targetPath)
            }
            
        } catch {
            
            // We know that the input path exists, but treating it as an alias
            // file failed, so we assume it's not an alias file and return its
            // *own* full path.
        }
        
        return self
    }
    
    // Resolves the true path of a URL, resolving sym links and Finder aliases, and determines whether the URL points to a directory
    var resolvedURL: URL {
        self.resolvingSymlinksInPath().resolvingAlias()
    }
    
    var isAliasOrSymLink: Bool {
        
        guard self.exists else {return false}
        
        let values = try? resourceValues(forKeys: [.isSymbolicLinkKey, .isAliasFileKey])
        
        if let alias = values?.isAliasFile, alias {
            return true
        }
           
        if let symbolicLink = values?.isSymbolicLink, symbolicLink {
            return true
        }
        
        return false
    }
    
    func lastPathComponents(count: Int) -> String {
        
        let actualComponents = self.pathComponents
        
        if actualComponents.count <= count + 1 {
            return self.path
        }
        
        var path: String = ""
        
        let lastIndex = actualComponents.count - 1
        let firstIndex = lastIndex - count + 1
        
        for index in (firstIndex...lastIndex).reversed() {
            path = String(format: "/%@%@", actualComponents[index], path)
        }
        
        return "..." + path
    }
    
    // Opens a Finder window, with the given file selected within it
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([self])
    }
    
    static func showInFinder(_ urls: [URL]) {
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }
}

struct FileAttributes {
    
    let size: FileSize?
    let lastModified: Date?
    let creationDate: Date?
    let kindOfFile: String?
    let lastOpened: Date?
}
