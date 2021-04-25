import Foundation

class FavoriteState: PersistentStateProtocol {

    let file: URL
    let name: String
    
    init(file: URL, name: String) {
        
        self.file = file
        self.name = name
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let file = map.urlValue(forKey: "file"),
              let name = map.stringValue(forKey: "name") else {return nil}
        
        self.file = file
        self.name = name
    }
}
