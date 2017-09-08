import Foundation

protocol PlaylistIOProtocol {
    
    // Save playlist tracks to given file
    func saveToFile(_ file: URL)
    
    // Load (append) playlist tracks from given file, at the end of the existing playlist. Existing tracks will be preserved.
    func loadFromFile(_ file: URL)
    
    // Gets a playlist representation suitable for persistence as app state
    func persistentState() -> PlaylistState
}
