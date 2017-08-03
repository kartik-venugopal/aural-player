/*
    Container for metadata about an ongoing recording
 */

import Foundation

class RecordingInfo {
    
    // Duration in seconds
    var duration: Double
   
    // Size of recording file on disk
    var fileSize: Size
    
    init(_ duration: Double, _ fileSize: Size) {
        self.duration = duration
        self.fileSize = fileSize
    }
}
