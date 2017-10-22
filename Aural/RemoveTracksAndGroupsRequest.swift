import Foundation

class RemoveTracksAndGroupsRequest {
    
    var mappings: [(group: Group, groupIndex: Int, tracks: [Track]?, groupRemoved: Bool)]
    
    init(_ mappings: [(group: Group, groupIndex: Int, tracks: [Track]?, groupRemoved: Bool)]) {
        self.mappings = mappings
    }
}
