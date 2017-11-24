/*
    Container for metadata about an ongoing recording
 */

import Foundation

struct RecordingInfo {
    
    // Audio format of the recording
    let format: RecordingFormat
    
    // Duration in seconds
    let duration: Double
   
    // Size of recording file on disk
    let fileSize: Size
    
    init(_ format: RecordingFormat, _ duration: Double, _ fileSize: Size) {
        
        self.format = format
        self.duration = duration
        self.fileSize = fileSize
    }
}
