import Foundation

class TranscoderState: PersistentState {
    
    var entries: [URL: URL] = [:]
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = TranscoderState()
        
        if let entries = map["entries"] as? NSDictionary {
            
            for (inFilePath, outFilePath) in entries {
                
                let inFile = URL(fileURLWithPath: String(describing: inFilePath))
                let outFile = URL(fileURLWithPath: String(describing: outFilePath))
                state.entries[inFile] = outFile
            }
        }
        
        return state
    }
}

extension Transcoder: PersistentModelObject {
    
    var persistentState: PersistentState {
        
        let state = TranscoderState()
        state.entries = store.files.kvPairs
        return state
    }
}
