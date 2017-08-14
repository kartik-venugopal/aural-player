
import Foundation

enum EQPresets: String {
    
    case flat // default
    case highBassAndTreble
    case karaoke
    case vocal
    case soft
    
    var description: String {
        return Utils.splitCamelCaseWord(rawValue, false)
    }
    
    static func fromDescription(_ description: String) -> EQPresets {
        return EQPresets(rawValue: Utils.camelCase(description)) ?? .flat
    }
    
    var bands: [Int: Float] {
        
        switch self {
            
        case .flat: return flatBands
        case .highBassAndTreble: return highBassAndTrebleBands
        case .soft: return softBands
        case .vocal: return vocalBands
        case .karaoke: return karaokeBands
        }
    }
    
    fileprivate var flatBands: [Int: Float] {
        
        var bands = [Int: Float]()
        
        // Freqs are powers of 2, starting with 2^5=32 ... 2^14=16k
        for i in 5...14 {
            bands[Int(pow(2.0, Double(i)))] = 0
        }
        
        return bands
    }
    
    fileprivate var highBassAndTrebleBands: [Int: Float] {
        
        var bands = [Int: Float]()
        
        // High bass
        bands[32] = 15
        bands[64] = 12.5
        bands[128] = 10
        
        // (Tapering) low mids
        bands[256] = 6
        bands[512] = 4
        bands[1024] = 4
        bands[2048] = 6
        
        // High treble
        bands[4096] = 10
        bands[8192] = 12.5
        bands[16384] = 15
        
        return bands
    }
    
    fileprivate var softBands: [Int: Float] {
        
        var bands = [Int: Float]()
        
        // Low bass
        bands[32] = 0
        bands[64] = 1
        bands[128] = 2
        
        // Moderate mids
        bands[256] = 6
        bands[512] = 8
        bands[1024] = 10
        bands[2048] = 12
        
        // Moderate to high treble
        bands[4096] = 12
        bands[8192] = 13
        bands[16384] = 14
        
        return bands
    }
    
    fileprivate var karaokeBands: [Int: Float] {
        
        var bands = [Int: Float]()
        
        // High bass
        bands[32] = 15
        bands[64] = 12.5
        bands[128] = 10
        
        // No mids
        bands[256] = -20
        bands[512] = -20
        bands[1024] = -20
        bands[2048] = -20
        
        // High treble
        bands[4096] = 10
        bands[8192] = 12.5
        bands[16384] = 15
        
        return bands
    }
    
    fileprivate var vocalBands: [Int: Float] {
        
        var bands = [Int: Float]()
        
        // Low bass
        bands[32] = -20
        bands[64] = -20
        bands[128] = -20
        
        // High mids
        bands[256] = 12
        bands[512] = 14
        bands[1024] = 14
        bands[2048] = 12
        
        // Low treble
        bands[4096] = -20
        bands[8192] = -20
        bands[16384] = -20
        
        return bands
    }
}
