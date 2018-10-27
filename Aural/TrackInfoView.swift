import Cocoa

class TrackInfoView: NSView {
    
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    // Fields that display information about the current playback sequence
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    func showOrHideSequenceInfo() {
        
        PlayerViewState.showSequenceInfo = !PlayerViewState.showSequenceInfo
        
        [lblPlaybackScope, lblSequenceProgress, imgScope].forEach({$0?.showIf(PlayerViewState.showSequenceInfo)})
        positionTrackInfoLabels()
    }
    
    func showNowPlayingInfo(_ track: Track, _ playbackState: PlaybackState, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.displayInfo.hasArtistAndTitle()) {
            
            artistAndTitleAvailable = true
            
            // Both title and artist
            if let album = track.groupingInfo.album {
                lblTrackArtist.stringValue = String(format: "%@ -- %@", track.displayInfo.artist!, album)
            } else {
                lblTrackArtist.stringValue = track.displayInfo.artist!
            }
            
            lblTrackTitle.stringValue = track.displayInfo.title!
            
        } else {
            
            lblTrackName.stringValue = track.conciseDisplayName
            positionTrackNameLabel()
        }
        
        lblTrackName.hideIf(artistAndTitleAvailable)
        [lblTrackArtist, lblTrackTitle].forEach({$0?.showIf(artistAndTitleAvailable)})
        
        showPlaybackScope(sequence)
    }
    
    fileprivate func positionTrackInfoLabels() {
        positionTrackNameLabel()
    }
    
    fileprivate func positionTrackNameLabel() {
        
        // Re-position and resize the track name label, depending on whether it is displaying one or two lines of text (i.e. depending on the length of the track name)
        
        // Determine how many lines the track name will occupy, within the label
        let numLines = StringUtils.numberOfLines(lblTrackName.stringValue, lblTrackName.font!, lblTrackName.frame.width)
        
        // The height is a pre-determined constant
        var lblFrameSize = lblTrackName.frame.size
        
        // TODO: Remove the constants, use artist/title label heights instead
        lblFrameSize.height = numLines == 1 ? lblTrackTitle.frame.height : lblTrackTitle.frame.height * 1.5
        
        // The Y co-ordinate is a pre-determined constant
        var origin = lblTrackName.frame.origin
        if numLines == 1 {
            
            // Center it wrt artist/title labels
            origin.y = lblTrackArtist.frame.minY + ((lblTrackArtist.frame.height + lblTrackTitle.frame.height) / 2) - (lblTrackName.frame.height / 2)
            
        } else {
            
            origin.y = lblTrackArtist.frame.minY
        }
        
        // Resize the label
        lblTrackName.setFrameSize(lblFrameSize)
        
        // Re-position the label
        lblTrackName.setFrameOrigin(origin)
    }
    
    /*
     Displays information about the current playback scope (i.e. the set of tracks that make up the current playback sequence - for ex. a specific artist group, or all tracks), and progress within that sequence - for ex. 5/67 (5th track playing out of a total of 67 tracks).
     */
    func showPlaybackScope(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        let scope = sequence.scope
        
        // Description and image for playback scope
        switch scope.type {
            
        case .allTracks, .allArtists, .allAlbums, .allGenres:
            
            lblPlaybackScope.stringValue = StringUtils.splitCamelCaseWord(scope.type.rawValue, false)
            imgScope.image = Images.imgPlaylistOn
            
        case .artist, .album, .genre:
            
            lblPlaybackScope.stringValue = scope.scope!.name
            imgScope.image = Images.imgGroup_noPadding
        }
        
        // Sequence progress. For example, "5 / 10" (tracks)
        let trackIndex = sequence.trackIndex
        let totalTracks = sequence.totalTracks
        lblSequenceProgress.stringValue = String(format: "%d / %d", trackIndex, totalTracks)
        
        positionScopeImage()
    }
    
    fileprivate func positionScopeImage() {
        
        // Dynamically position the scope image relative to the scope description string
        
        // Determine the width of the scope string
        let scopeString: NSString = lblPlaybackScope.stringValue as NSString
        let stringSize: CGSize = scopeString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): lblPlaybackScope.font as AnyObject]))
        let lblWidth = lblPlaybackScope.frame.width
        let textWidth = min(stringSize.width, lblWidth)
        
        // Position the scope image a few pixels to the left of the scope string
        let margin = (lblWidth - textWidth) / 2
        let newImgX = lblPlaybackScope.frame.origin.x + margin - imgScope.frame.width - 4
        imgScope.frame.origin.x = max(lblTrackTitle.frame.minX, newImgX)
    }
    
    func clearNowPlayingInfo() {
        
        [lblTrackName, lblTrackArtist, lblTrackTitle, lblPlaybackScope, lblSequenceProgress].forEach({$0?.stringValue = ""})
        imgScope.image = nil
    }
    
    func sequenceChanged(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        lblSequenceProgress.stringValue = String(format: "%d / %d", sequence.trackIndex, sequence.totalTracks)
    }
    
    func handOff(_ otherView: TrackInfoView) {
        
        //        otherView.lblTrackName.stringValue = lblTrackName.stringValue
        //        otherView.lblTrackTitle.stringValue = lblTrackTitle.stringValue
        //        otherView.lblTrackArtist.stringValue = lblTrackArtist.stringValue
        //        otherView.artView.image = artView.image
        //        otherView.imgScope.image = imgScope.image
        //        otherView.lblPlaybackScope.stringValue = lblPlaybackScope.stringValue
        //        otherView.lblSequenceProgress.stringValue = lblSequenceProgress.stringValue
        //
        //        otherView.lblTrackName.showIf(lblTrackName.isShown)
        //        otherView.lblTrackTitle.showIf(lblTrackTitle.isShown)
        //        otherView.lblTrackArtist.showIf(lblTrackArtist.isShown)
        //
        //        otherView.positionTrackNameLabel()
        //        otherView.positionScopeImage()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
