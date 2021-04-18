import Cocoa

class StatusBarSettingsViewController: NSViewController {
    
    @IBOutlet weak var btnShowArt: NSButton!
    @IBOutlet weak var btnShowArtist: NSButton!
    @IBOutlet weak var btnShowAlbum: NSButton!
    @IBOutlet weak var btnShowChapterTitle: NSButton!
    
    @IBOutlet weak var trackInfoView: StatusBarPlayingTrackTextView!
    @IBOutlet weak var imgArt: NSImageView!
    @IBOutlet weak var artOverlayBox: NSBox!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    override func viewWillAppear() {
        
        btnShowArt.onIf(StatusBarPlayerViewState.showAlbumArt)
        btnShowArtist.onIf(StatusBarPlayerViewState.showArtist)
        btnShowAlbum.onIf(StatusBarPlayerViewState.showAlbum)
        
        btnShowChapterTitle.showIf(player.playingTrack?.hasChapters ?? false)
        btnShowChapterTitle.onIf(StatusBarPlayerViewState.showCurrentChapter)
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSButton) {
        
        StatusBarPlayerViewState.showAlbumArt.toggle()
        [imgArt, artOverlayBox].forEach {$0.showIf(StatusBarPlayerViewState.showAlbumArt)}
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSButton) {
        
        StatusBarPlayerViewState.showArtist.toggle()
        trackInfoView.update()
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSButton) {
        
        StatusBarPlayerViewState.showAlbum.toggle()
        trackInfoView.update()
    }
    
    @IBAction func showOrHideChapterTitleAction(_ sender: NSButton) {
        
        StatusBarPlayerViewState.showCurrentChapter.toggle()
        trackInfoView.update()
    }
}
