import Foundation

class TranscoderStore: MessageSubscriber {
    
    let baseDir: URL
    var map: [URL: URL] = [:]
    
    let preferences: TranscodingPreferences
    
    let subscriberId: String = "TranscoderStore"
    
    // TODO: Accessing delegate here ?
    private lazy var history: HistoryDelegateProtocol = ObjectGraph.historyDelegate

    init(_ state: TranscoderState, _ preferences: TranscodingPreferences) {
        
        self.preferences = preferences
        
        baseDir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("transcoderStore", isDirectory: true)
        FileSystemUtils.createDirectory(baseDir)
        
        if preferences.persistenceOption == .save {
            
            state.entries.forEach({
                map[$0.key] = $0.value
            })
        }
        
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
    }
    
    func createOutputFile(_ track: Track, _ outputFileName: String) -> URL {
        return baseDir.appendingPathComponent(outputFileName, isDirectory: false)
    }
    
    // When transcoding is canceled
    func deleteEntry(_ track: Track) {
        
        if let outputFile = map[track.file] {
            FileSystemUtils.deleteFile(outputFile.path)
        }
        
        map.removeValue(forKey: track.file)
    }
    
    // Notification from Transcoder that a new file has been added to the store. Need to check that store disk space usage is under the user-preferred limit.
    func addFileMapping(_ track: Track, _ outputFile: URL) {
        
        map[track.file] = outputFile
        
        // Couple of seconds delay to allow the track that was just transcoded to be added to the "Recently played " History list (this is needed for the comparison between tracks)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2, execute: {
            
            // Do this async, as a background task, so as not to interfere with user-interactive tasks
            if self.preferences.persistenceOption == .save && self.preferences.limitDiskSpaceUsage {
                
                let maxUsage = self.preferences.maxDiskSpaceUsage * (1000 * 1000)
                var curUsage: UInt64 = FileSystemUtils.sizeOfDirectory(self.baseDir)
                
                if curUsage > maxUsage {
                    
                    // Gather all files, sort chronologically
                    var trackFiles: [URL] = []
                    trackFiles.append(contentsOf: self.map.keys)
                    trackFiles.sort(by: self.compareFiles(_:_:))
                    
                    var outputFiles: [URL] = []
                    trackFiles.forEach({outputFiles.append(self.map[$0]!)})
                    
                    while curUsage > maxUsage {

                        // Delete the oldest file
                        let fileToDelete = outputFiles.removeLast()
                        
                        if fileToDelete.path == outputFile.path {
                            // Cannot delete playing file, just exit and retry when next file is transcoded
                            return
                        }
                        
                        // Update current usage variable (subtract deleted file's size)
                        curUsage -= UInt64(FileSystemUtils.sizeOfFile(path: fileToDelete.path).sizeBytes)

                        // Delete the file from the filesystem and from the map
                        FileSystemUtils.deleteFile(fileToDelete.path)
                        self.map.removeValue(forKey: trackFiles.removeLast())
                    }
                }
            }
        })
    }
    
    func compareFiles(_ file1: URL, _ file2: URL) -> Bool {
        
        let result = history.compareChronologically(file1, file2)
        
        // If history says they're equal, use file modification date as criteria (oldest modified file gets deleted)
        if result == .orderedSame {
            
            // Use output files for comparison, not input files
            let f1 = map[file1]!
            let f2 = map[file2]!
            return FileSystemUtils.compareFileModificationDates(f1, f2) == .orderedDescending
        }
        
        return result == .orderedAscending
    }

    func getForTrack(_ track: Track) -> URL? {
        
        if let outFile = map[track.file] {
            
            if FileSystemUtils.fileExists(outFile) {
                return outFile
            }
            
            map.removeValue(forKey: track.file)
        }
        
        return nil
    }

    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        if preferences.persistenceOption == .delete {
            FileSystemUtils.deleteContentsOfDirectory(baseDir)
            map.removeAll()
        }
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
}
