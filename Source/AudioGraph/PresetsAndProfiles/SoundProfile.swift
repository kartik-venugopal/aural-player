import Foundation

class SoundProfiles: TrackKeyedMap<SoundProfile> {
}

struct SoundProfile {
    
    let file: URL
    
    let volume: Float
    let balance: Float
    
    let effects: MasterPreset
}

class TrackKeyedMap<T> {

    var map: [URL: T] = [:]
    
    func add(_ track: Track, _ item: T) {
        map[track.file] = item
    }
    
    func add(_ file: URL, _ item: T) {
        map[file] = item
    }
    
    func get(_ track: Track) -> T? {
        return map[track.file]
    }
    
    func hasFor(_ track: Track) -> Bool {
        return get(track) != nil
    }
    
    func remove(_ track: Track) {
        map[track.file] = nil
    }
    
    func removeAll() {
        map.removeAll()
    }
    
    func all() -> [T] {
        return [T](map.values)
    }
    
    var size: Int {
        return map.count
    }
}
