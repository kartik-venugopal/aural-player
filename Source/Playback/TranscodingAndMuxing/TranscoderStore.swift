import Foundation

class TranscoderStore: MessageSubscriber {
    
    // TODO: Be more careful when deleting files from file system (don't want to delete unrelated files)
    
    let baseDir: URL
    
    var files: ConcurrentMap<URL, URL> = ConcurrentMap("transcoderStore-files")
    var filesBeingTranscoded: ConcurrentMap<URL, URL> = ConcurrentMap("transcoderStore-filesBeingTranscoded")
    
    let preferences: TranscodingPreferences
    
    var currentDiskSpaceUsage: UInt64 {return FileSystemUtils.sizeOfDirectory(baseDir)}
    
    // TODO: Accessing delegate here ?
//    private lazy var history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
//    private lazy var player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let backgroundQueue: DispatchQueue = DispatchQueue.global(qos: .background)
    
    init(_ state: TranscoderState, _ preferences: TranscodingPreferences) {
        
        self.preferences = preferences
        
        baseDir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("transcoderStore", isDirectory: true)
        FileSystemUtils.createDirectory(baseDir)
        
        if preferences.persistenceOption == .save {
            
            state.entries.forEach({
                files[$0.key] = $0.value
            })
        }
        
        Messenger.subscribe(self, Notifications.appExitRequest, self.onAppExit(_:))
        
//        backgroundQueue.async {
//            self.cleanUpMappings()
//        }
    }
    
    func createOutputFile(_ track: Track, _ outputFileName: String) -> URL {
        
        if let existingFile = filesBeingTranscoded[track.file] {
            return existingFile
        }
        
        let file = baseDir.appendingPathComponent(outputFileName, isDirectory: false)
        filesBeingTranscoded[track.file] = file
        
        return file
    }
    
    func transcodingCancelledOrFailed(_ file: URL) {
        
        // Remove mapping and filesystem file
        
        // TODO: Add a method to ConcurrentMap that does this (removeValue), if possible.
        for (inFile, outFile) in filesBeingTranscoded.kvPairs {
            
            if outFile == file {
                _ = filesBeingTranscoded.remove(inFile)
                break
            }
        }
        
        backgroundQueue.async {
            FileSystemUtils.deleteFile(file.path)
        }
    }
    
    // Notification from Transcoder that a new file has been added to the store. Need to check that store disk space usage is under the user-preferred limit.
    func transcodingFinished(_ track: Track) {
        
        files[track.file] = filesBeingTranscoded.remove(track.file)
        
        // HACK: Couple of seconds delay to allow the track that was just transcoded to be added to the "Recently played" History list (this is needed for the comparison between tracks)
//        backgroundQueue.asyncAfter(deadline: .now() + 2, execute: {
//            self.checkDiskSpaceUsage()
//        })
    }
    
    func getForTrack(_ track: Track) -> URL? {
        
        if let outFile = files[track.file] {
            
            if FileSystemUtils.fileExists(outFile) {
                return outFile
            }
            
            // File doesn't exist in the filesystem, so remove it from the map (because it's an invalid mapping).
            _ = files.remove(track.file)
        }
        
        return nil
    }
    
    func hasForTrack(_ track: Track) -> Bool {

        if let outFile = files[track.file], FileSystemUtils.fileExists(outFile) {
            return true
        }
        
        return false
    }
    
    // MARK: Message handling

    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    func onAppExit(_ request: AppExitRequestNotification) {
        
        if preferences.persistenceOption == .delete {
            
            FileSystemUtils.deleteContentsOfDirectory(baseDir)
            files.removeAll()
            
        } else {
            
            // Clean up files that are unmapped
            
            let allFiles = FileSystemUtils.getContentsOfDirectory(baseDir)!
            let mappedFiles = files.values
            let unmappedFiles = allFiles.filter({!mappedFiles.contains($0)})
            
            // Clean up the store folder
            for file in unmappedFiles {
                FileSystemUtils.deleteFile(file.path)
            }
        }
        
        // Proceed with exit
        request.appendResponse(okToExit: true)
    }
    
    //    func checkDiskSpaceUsage() {
    //
    //        if self.preferences.limitDiskSpaceUsage {
    //
    //            backgroundQueue.async {
    //
    //                // Do this async, as a background task, so as not to interfere with user-interactive tasks
    //                self.cleanUpMappings()
    //
    //                if self.files.isEmpty {return}
    //
    //                let maxUsage = self.preferences.maxDiskSpaceUsage * (1000 * 1000)
    //                var curUsage: UInt64 = FileSystemUtils.sizeOfDirectory(self.baseDir)
    //
    //                if curUsage > maxUsage {
    //
    //                    // Gather all files, sort chronologically
    //                    var trackFiles: [URL] = []
    //                    trackFiles.append(contentsOf: self.files.keys)
    //
    //                    trackFiles.sort(by: self.compareFiles(_:_:))
    //
    //                    var outputFiles: [URL] = []
    //                    trackFiles.forEach({outputFiles.append(self.files[$0]!)})
    //
    //                    while curUsage > maxUsage && !trackFiles.isEmpty {
    //
    //                        // Delete the oldest file
    //                        let fileToDelete = outputFiles.removeLast()
    //
    //                        // Don't delete playing track !
    //                        if let plTrack = self.player.playingTrack?.track, let outFile = self.files[plTrack.file], fileToDelete.path == outFile.path {
    //                            return
    //                        }
    //
    //                        self.files.removeValue(forKey: trackFiles.removeLast())
    //
    //                        // Update current usage variable (subtract deleted file's size)
    //                        curUsage -= UInt64(FileSystemUtils.sizeOfFile(path: fileToDelete.path).sizeBytes)
    //
    //                        // Delete the file from the filesystem and from the map
    //                        FileSystemUtils.deleteFile(fileToDelete.path)
    //                    }
    //                }
    //            }
    //        }
    //    }
        
    //    private func cleanUpMappings() {
    //
    //        let allFiles = FileSystemUtils.getContentsOfDirectory(baseDir)!
    //        let mappedFiles = files.values
    //        let inProgressFiles = filesBeingTranscoded.values
    //
    //        // Clean up the store folder
    //        for file in allFiles {
    //
    //            if !mappedFiles.contains(file) && !inProgressFiles.contains(file) {
    //                FileSystemUtils.deleteFile(file.path)
    //            }
    //        }
    //
    //        // Clean up the map
    //        for (trackFile, outputFile) in self.files {
    //
    //            if !FileSystemUtils.fileExists(outputFile) {
    //                self.files.removeValue(forKey: trackFile)
    //            }
    //        }
    //    }
    //
    //    func compareFiles(_ file1: URL, _ file2: URL) -> Bool {
    //
    //        let result = history.compareChronologically(file1, file2)
    //
    //        // If history says they're equal, use file modification date as criteria (oldest modified file gets deleted)
    //        if result == .orderedSame {
    //
    //            // Use output files for comparison, not input files
    //            let f1 = files[file1]!
    //            let f2 = files[file2]!
    //            return FileSystemUtils.compareFileModificationDates(f1, f2) == .orderedDescending
    //        }
    //
    //        return result == .orderedAscending
    //    }
}
