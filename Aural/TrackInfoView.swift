import Cocoa

class TrackInfoView: NSView {
    
    @IBOutlet weak var lblArtist: NSTextField!
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblName: NSTextField!
    
    // Fields that display information about the current playback sequence
    @IBOutlet weak var lblScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    func showView(_ playbackState: PlaybackState) {
        
        [lblScope, imgScope].forEach({$0?.showIf_elseHide(PlayerViewState.showSequenceInfo)})
        positionTrackInfoLabels()
    }
    
    func showOrHideSequenceInfo() {
        
        PlayerViewState.showSequenceInfo = !PlayerViewState.showSequenceInfo
        
        [lblScope, imgScope].forEach({$0?.showIf_elseHide(PlayerViewState.showSequenceInfo)})
        positionTrackInfoLabels()
    }
    
    func showNowPlayingInfo(_ track: Track, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.displayInfo.hasArtistAndTitle()) {
            
            artistAndTitleAvailable = true
            
            // Both title and artist
            if let album = track.groupingInfo.album {
                lblArtist.stringValue = String(format: "%@ -- %@", track.displayInfo.artist!, album)
            } else {
                lblArtist.stringValue = track.displayInfo.artist!
            }
            
            lblTitle.stringValue = track.displayInfo.title!
            
        } else {
            
            lblName.stringValue = track.conciseDisplayName
            positionTrackNameLabel()
        }
        
        lblName.hideIf_elseShow(artistAndTitleAvailable)
        [lblArtist, lblTitle].forEach({$0?.showIf_elseHide(artistAndTitleAvailable)})
        
        showPlaybackScope(sequence)
    }
    
    fileprivate func positionTrackInfoLabels() {
        
        // Re-position and resize the track name label, depending on whether it is displaying one or two lines of text (i.e. depending on the length of the track name)
        
        let top: CGFloat = self.frame.height
        let midPoint: CGFloat = self.frame.height / 2
        
        if PlayerViewState.showSequenceInfo {
        
            lblTitle.frame.origin.y = top - lblTitle.frame.height - 3
            lblArtist.frame.origin.y = lblTitle.frame.origin.y - lblArtist.frame.height + 2
            
        } else {
        
            lblArtist.frame.origin.y = midPoint - lblArtist.frame.height + 4
            lblTitle.frame.origin.y = lblArtist.frame.maxY - 2
        }
        
        positionTrackNameLabel()
    }
    
    fileprivate func positionTrackNameLabel() {
        
        // Re-position and resize the track name label, depending on whether it is displaying one or two lines of text (i.e. depending on the length of the track name)
        
        // Determine how many lines the track name will occupy, within the label
        let numLines = StringUtils.numberOfLines(lblName.stringValue, lblName.font!, lblName.frame.width)
        
        // The height is dependent on the number of lines
        var lblFrameSize = lblName.frame.size
        lblFrameSize.height = numLines == 1 ? lblTitle.frame.height : lblTitle.frame.height * 1.5
        
        // The Y co-ordinate is a function of the other labels' positions
        var origin = lblName.frame.origin
        
        // Center it wrt artist/title labels
        origin.y = numLines == 1 ? lblArtist.frame.minY + ((lblArtist.frame.height + lblTitle.frame.height) / 2) - (lblName.frame.height / 2) : lblArtist.frame.minY
        
        // Resize the label
        lblName.setFrameSize(lblFrameSize)
        
        // Re-position the label
        lblName.setFrameOrigin(origin)
    }
    
    /*
     Displays information about the current playback scope (i.e. the set of tracks that make up the current playback sequence - for ex. a specific artist group, or all tracks), and progress within that sequence - for ex. 5/67 (5th track playing out of a total of 67 tracks).
     */
    func showPlaybackScope(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        let scope = sequence.scope
        var scopeStr: String
        
        // Description and image for playback scope
        switch scope.type {
            
        case .allTracks, .allArtists, .allAlbums, .allGenres:
            
            scopeStr = StringUtils.splitCamelCaseWord(scope.type.rawValue, false)
            imgScope.image = Images.imgPlaylist_padded
            
        case .artist, .album, .genre:
            
            scopeStr = scope.scope!.name
            imgScope.image = Images.imgGroup_noPadding
        }
        
        // Sequence progress. For example, "5 / 10" (tracks)
        let sequenceStr = String(format: "  [ %d / %d ]", sequence.trackIndex, sequence.totalTracks)
        let seqWidth = StringUtils.widthOfString(sequenceStr, lblScope.font!)
        
        let scopeMaxWidth = lblScope.frame.width - seqWidth - 10
        let truncatedScope = StringUtils.truncate(scopeStr, lblScope.font!, scopeMaxWidth)
        
        lblScope.stringValue = truncatedScope + sequenceStr
        
        positionScopeImage()
    }
    
    fileprivate func positionScopeImage() {
        
        // Dynamically position the scope image relative to the scope description string
        
        // Determine the width of the scope string
        let scopeString: NSString = lblScope.stringValue as NSString
        let stringSize: CGSize = scopeString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): lblScope.font as AnyObject]))
        let lblWidth = lblScope.frame.width
        let textWidth = min(stringSize.width, lblWidth)
        
        // Position the scope image a few pixels to the left of the scope string
        let margin = (lblWidth - textWidth) / 2
        let newImgX = lblScope.frame.origin.x + margin - imgScope.frame.width - 4
        imgScope.frame.origin.x = max(lblTitle.frame.minX, newImgX)
    }
    
    func clearNowPlayingInfo() {
        
        [lblName, lblArtist, lblTitle, lblScope].forEach({$0?.stringValue = ""})
        imgScope.image = nil
    }
    
    func sequenceChanged(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        showPlaybackScope(sequence)
    }
    
    func handOff(_ otherView: TrackInfoView) {
        
        otherView.lblName.stringValue = lblName.stringValue
        otherView.lblTitle.stringValue = lblTitle.stringValue
        otherView.lblArtist.stringValue = lblArtist.stringValue
        
        otherView.lblName.showIf_elseHide(lblName.isShown)
        otherView.lblTitle.showIf_elseHide(lblTitle.isShown)
        otherView.lblArtist.showIf_elseHide(lblArtist.isShown)
        
        otherView.imgScope.image = imgScope.image
        otherView.lblScope.stringValue = lblScope.stringValue
        
        otherView.positionTrackInfoLabels()
        otherView.positionScopeImage()
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
