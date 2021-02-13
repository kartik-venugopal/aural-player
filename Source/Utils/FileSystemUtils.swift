/*
    A collection of useful utilities for file system operations
 */
import Cocoa

class FileSystemUtils {
    
    private static let fileManager: FileManager = FileManager.default
    
    // Checks if a file exists
    static func fileExists(_ file: URL) -> Bool {
        return fileManager.fileExists(atPath: file.path)
    }
    
    // Checks if a file exists
    static func fileExists(_ path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
    
    static func createDirectory(_ dir: URL) {
        
        if fileExists(dir) {
            return
        }
        
        do
        {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory '%@' \(error.debugDescription)", dir.path)
        }
    }
    
    // Renames a file
    static func renameFile(_ src: URL, _ target: URL) {
        do {
            try fileManager.moveItem(at: src, to: target)
        } catch let error as NSError {
            NSLog("Error renaming file '%@' to '%@': %@", src.path, target.path, error.description)
        }
    }
    
    // Deletes a file
    static func deleteFile(_ path: String) {
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error as NSError {
            NSLog("Error deleting file '%@': %@", path, error.description)
        }
    }
    
    // Deletes all contents of a directory
    static func deleteContentsOfDirectory(_ dir: URL) {
        
        do {
            // Retrieve all files/subfolders within this folder
            let contents = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions())
            
            for file in contents {
                try fileManager.removeItem(atPath: file.path)
            }
            
        } catch let error as NSError {
            NSLog("Error retrieving/deleting contents of directory '%@': %@", dir.path, error.description)
        }
    }
    
    // Retrieves the contents of a directory
    static func getContentsOfDirectory(_ dir: URL) -> [URL]? {
        
        do {
            // Retrieve all files/subfolders within this folder
            let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions())
            
            // Add them
            return files
            
        } catch let error as NSError {
            NSLog("Error retrieving contents of directory '%@': %@", dir.path, error.description)
            return nil
        }
    }
    
    static func sizeOfDirectory(_ dir: URL) -> UInt64 {
        
        var size: UInt64 = 0
        
        do {
            // Retrieve all files/subfolders within this folder
            let contents = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions())
            
            for file in contents {
                
                let attr = try fileManager.attributesOfItem(atPath: file.path)
                size += attr[FileAttributeKey.size] as! UInt64
            }
            
        } catch let error as NSError {
            NSLog("Error retrieving contents of directory '%@': %@", dir.path, error.description)
        }
        
        return size
    }
 
    // Determines whether or not a file (must be resolved) is a directory
    static func isDirectory(_ url: URL) -> Bool {
        
        do {
            let attr = try fileManager.attributesOfItem(atPath: url.path)
            return (attr[FileAttributeKey.type] as! FileAttributeType) == FileAttributeType.typeDirectory
            
        } catch let error as NSError {
            NSLog("Error getting type of file at url '%@': %@", url.path, error.description)
            return false
        }
    }
    
    static func compareFileModificationDates(_ file1: URL, _ file2: URL) -> ComparisonResult {
        
        do {
            
            let attrs1 = try fileManager.attributesOfItem(atPath: file1.path)
            let date1 = attrs1[FileAttributeKey.modificationDate] as! Date
            
            let attrs2 = try fileManager.attributesOfItem(atPath: file2.path)
            let date2 = attrs2[FileAttributeKey.modificationDate] as! Date
            
            return date1.compare(date2)
            
        } catch let error as NSError {
            
            NSLog("Error getting creation dates of files at urls '%@' and '%@': %@", file1.path, file2.path, error.description)
            return .orderedSame
        }
    }
    
    // Computes the size of a file, and returns a convenient representation
    static func sizeOfFile(path: String) -> Size {
        
        var fileSize : UInt64
        
        do {
            let attr = try fileManager.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            return Size(sizeBytes: UInt(fileSize))
            
        } catch let error as NSError {
            NSLog("Error getting size of file '%@': %@", path, error.description)
        }
        
        return Size.ZERO
    }
    
    static func fileAttributes(path: String) -> (size: Size?, lastModified: Date?, creationDate: Date?, kindOfFile: String?, lastOpened: Date?) {
        
        var fileSize : Size?
        var lastModified: Date?
        var creationDate: Date?
        var kindOfFile: String?
        var lastOpened: Date?
        
        if let mditem = MDItemCreate(nil, path as CFString),
            
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
            
            kindOfFile = mdattrs[kMDItemKind as String] as? String
            lastOpened = mdattrs[kMDItemLastUsedDate as String] as? Date
        }
        
        do {

            let attr = try fileManager.attributesOfItem(atPath: path)
            fileSize = Size(sizeBytes: attr[FileAttributeKey.size] as! UInt)
            
            if let modDate = attr[FileAttributeKey.modificationDate] as? Date {
                lastModified = modDate
            }
            
            if let cDate = attr[FileAttributeKey.creationDate] as? Date {
                creationDate = cDate
            }
            
        } catch let error as NSError {
            NSLog("Error getting size of file '%@': %@", path, error.description)
        }
        
        return (fileSize, lastModified, creationDate, kindOfFile, lastOpened)
    }
    
    // Computes a relative path of a target, relative to a source
    // For example, if src = /A/B/C/D.m3u, and target = /A/E.mp3, then the relative path = ../../../E.mp3
    static func relativePath(_ src: URL, _ target: URL) -> String {
        
        let sComps = src.deletingLastPathComponent().resolvingSymlinksInPath().pathComponents
        let tComps = target.deletingLastPathComponent().resolvingSymlinksInPath().pathComponents
        
        // Cursor for traversing the path components
        var cur = 0
        
        // Stays true as long as path components at each level match
        var pathMatch: Bool = true
        
        // Find common path
        // Example: if src = /A/B/C/D, and target = /A/E, then common path = /A
        while cur < sComps.count && cur < tComps.count && pathMatch {
            
            if (sComps[cur] != tComps[cur]) {
                pathMatch = false
            } else {
                cur += 1
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
        if (cur < tComps.count) {
            for i in cur...tComps.count - 1 {
                relPath.append(tComps[i] + "/")
            }
        }
        
        // Finally, append the target file name
        relPath.append(target.lastPathComponent)
        
        return relPath
    }
    
    // Resolves a Finder alias and returns its true file URL
    static func resolveAlias(_ file: URL) -> URL {
        
        var targetPath:String? = nil
        
        do {
            // Get information about the file alias.
            // If the file is not an alias files, an exception is thrown
            // and execution continues in the catch clause.
            
            let data = try URL.bookmarkData(withContentsOf: file)
            
            // NSURLPathKey contains the target path.
            let resourceValues = URL.resourceValues(forKeys: [URLResourceKey.pathKey], fromBookmarkData: data)
            targetPath = (resourceValues?.allValues[URLResourceKey.pathKey] as! String)
            
            return URL(fileURLWithPath: targetPath!)
            
        } catch {
            // We know that the input path exists, but treating it as an alias
            // file failed, so we assume it's not an alias file and return its
            // *own* full path.
            return file
        }
    }
    
    // Resolves the true path of a URL, resolving sym links and Finder aliases, and determines whether the URL points to a directory
    static func resolveTruePath(_ url: URL) -> (resolvedURL: URL, isDirectory: Bool) {
        
        let resolvedFile1 = url.resolvingSymlinksInPath()
        let resolvedFile2 = resolveAlias(resolvedFile1)
        let isDir = isDirectory(resolvedFile2)
        
        return (resolvedFile2, isDir)
    }
    
    static func getLastPathComponents(_ url: URL, _ numDesiredComponents: Int) -> String {
        
        let actualComponents = url.pathComponents
        
        if actualComponents.count <= numDesiredComponents + 1 {
            return url.path
        }
        
        var path: String = ""
        
        let lastIndex = actualComponents.count - 1
        let firstIndex = lastIndex - numDesiredComponents + 1
        
        for index in (firstIndex...lastIndex).reversed() {
            path = String(format: "/%@%@", actualComponents[index], path)
        }
        
        return "..." + path
    }

    // Opens a Finder window, with the given file selected within it
    static func showFileInFinder(_ file: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([file])
    }
}

class SystemUtils {
    
    static var numberOfActiveCores: Int {
        return ProcessInfo.processInfo.activeProcessorCount
    }
    
    static var osVersion: OperatingSystemVersion {
        return ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static var osMajorVersion: Int {
        return osVersion.majorVersion
    }
    
    static var osMinorVersion: Int {
        return osVersion.minorVersion
    }
    
    static var isBigSur: Bool {
        
        let os = osVersion
        return os.majorVersion > 10 || os.minorVersion > 15
    }
}
