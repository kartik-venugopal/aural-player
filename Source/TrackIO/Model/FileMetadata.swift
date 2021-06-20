import Foundation

class FileMetadata {
    
    var playlist: PlaylistMetadata?
    var playback: PlaybackContextProtocol?
    
    var isPlayable: Bool {validationError == nil}
    var validationError: DisplayableError?
}
