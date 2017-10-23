import Foundation

class RemoveTracksAndGroupsRequest {
    
    let groupType: GroupType
    let mappings: [(group: Group, groupIndex: Int, tracks: [Track]?, groupRemoved: Bool)]
    
    init(_ groupType: GroupType, _ mappings: [(group: Group, groupIndex: Int, tracks: [Track]?, groupRemoved: Bool)]) {
        self.groupType = groupType
        self.mappings = mappings
    }
}
