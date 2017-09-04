import Foundation

protocol PlaylistAccessor {
    
    func getTracks() -> [Track]
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack?
    
    func isEmpty() -> Bool
    
    func size() -> Int
}
