import Foundation

protocol GroupAccessorProtocol {
    
    var type: GroupType {get}
    
    var name: String {get}
    
    var duration: Double {get}
    
    func size() -> Int
    
    func trackAtIndex(_ index: Int) -> Track
    
    func indexOf(_ track: Track) -> Int?
}
