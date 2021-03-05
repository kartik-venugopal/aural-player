import AVFoundation

class AVFMetadataContext {
    
    private let track: Track
    
    private let asset: AVURLAsset
    private let assetTrack: AVAssetTrack
    
//    private let map: AVFMetadata
 
    init(for track: Track) throws {
        
        self.track = track
        self.asset = AVURLAsset(url: track.file, options: nil)
        
        // TODO: Test against a protected iTunes file
        if asset.hasProtectedContent {
            throw DRMProtectionError(track.file)
        }
        
        let assetTracks = asset.tracks(withMediaType: AVFoundation.AVMediaType.audio)
        
        // Check if the asset has any audio tracks
        guard let assetTrack = assetTracks.first else {
            throw NoAudioTracksError(track.file)
        }
        
        self.assetTrack = assetTrack
        
        // Find out if track is playable
        // TODO: What does isPlayable actually mean ?
        if !assetTrack.isPlayable {
            throw TrackNotPlayableError(track.file)
        }
        
//        self.map = AVAssetReader.buildMap(for: asset)
    }
    
    func loadPlaylistMetadata() {
//        track.metadata.setPlaylistMetadata(AVAssetReader.getPlaylistMetadata(from: map))
    }
    
    func loadSecondaryMetadata() {
//        track.metadata.setSecondaryMetadata(AVAssetReader.getSecondaryMetadata(from: map))
    }
    
    func loadAllMetadata() {
//        track.metadata.setGenericMetadata(AVAssetReader.getAllMetadata(from: map))
    }
}
