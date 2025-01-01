//
//  LyricsWindowController.swift
//  Aural
//
//  Created by tisfeng on 2024/12/3.
//

import Cocoa
import MusicPlayer
import SwiftUI
import LyricsUI
import LyricsService

let lyricsWindowWidth: CGFloat = 400
let lyricsWindowHeight: CGFloat = 625

/// Controller for the Lyrics window, host LyricsScrollView
class LyricsWindowController: NSWindowController {

    private var hostingView: NSHostingView<LyricsWrappedView>?
    private var lyricsView: LyricsWrappedView?

    private var track: Track?
    private var lyrics: Lyrics?
    private var elapsedTime: Double = 0
    private var isPlaying: Bool = false

    lazy var messenger = Messenger(for: self)

    fileprivate lazy var theDelegate: SnappingWindowDelegate = {
        SnappingWindowDelegate(window: self.window! as! SnappingWindow)
    }()

    override init(window: NSWindow?) {
        let window = SnappingWindow(
            contentRect: NSRect(x: 0, y: 0, width: lyricsWindowWidth, height: lyricsWindowHeight),
            styleMask: [.resizable],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.identifier = .init(rawValue: WindowID.lyrics.rawValue)
        window.center()

        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isMovableByWindowBackground = true

        super.init(window: window)

        window.delegate = theDelegate

        updateLyricsView()

        setupNotifications()

        colorSchemesManager.registerSchemeObservers(self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    convenience init(track: Track?, lyrics: Lyrics?) {
        self.init(window: nil)

        self.track = track
        self.lyrics = lyrics
        updateLyricsView()
    }

    deinit {
        messenger.unsubscribeFromAll()
    }

    // MARK: - View Management

    private func updateLyricsView() {
        let lyricsView = LyricsWrappedView(
            track: track?.musicTrack,
            lyrics: lyrics,
            elapsedTime: elapsedTime,
            isPlaying: isPlaying,
            onLyricsTap: { [weak self] index, proxy in
                let position = self?.lyrics?[index].position ?? 0
                self?.messenger.publish(.Player.jumpToTime, payload: position)
            },
            onLyricsUpdate: { [weak self] lyrics in
                self?.saveLyrics(lyrics)
            }
        )

        self.lyricsView = lyricsView

        if hostingView == nil {
            hostingView = NSHostingView(rootView: lyricsView)
            hostingView?.wantsLayer = true
            hostingView?.layer?.cornerRadius = playerUIState.cornerRadius
            hostingView?.layer?.masksToBounds = true
            window?.contentView = hostingView
        } else {
            hostingView?.rootView = lyricsView
        }

        applyColorScheme(systemColorScheme)

        lyricsView.seekTo(position: elapsedTime, isPlaying: isPlaying)
    }

    /// Update color theme
    func applyColorScheme(_ scheme: ColorScheme) {
        let isLightColorScheme = scheme.primaryTextColor == .black
        hostingView?.appearance = .init(named: isLightColorScheme ? .aqua : .darkAqua)
        hostingView?.layer?.backgroundColor = scheme.backgroundColor.cgColor
    }

    // MARK: - Setup

    private func setupNotifications() {
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned)
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: trackInfoUpdated(_:))
        messenger.subscribeAsync(to: .Player.trackNotPlayed, handler: trackTransitioned)
        messenger.subscribeAsync(to: .Player.playbackStateChanged, handler: playbackStateChanged)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: seekPerformed)
    }

    // MARK: - Update Methods

    private func updateTrackInfo() {
        track = playbackDelegate.playingTrack
        lyrics = track?.fetchLocalLyrics()
        updatePlaybackState()

        DispatchQueue.main.async {
            self.updateLyricsView()
        }
    }

    private func updatePlaybackState() {
        elapsedTime = playbackDelegate.seekPosition.timeElapsed
        isPlaying = playbackDelegate.state == .playing
    }

    /// Auto search lyrics if lyrics is nil
    private func autoSearchLyrics() {

        guard let track, lyrics == nil else {
            return
        }

        let searchService = LyricsSearchService()

        Task {
            let musicTrack = track.musicTrack
            let lyricsList = await searchService.searchLyrics(with: musicTrack.searchQuery)
            if let bestLyrics = lyricsList.bestMatch(for: musicTrack) {
                self.saveLyrics(bestLyrics)
            }
        }
    }

    /// Save lyrics to file, and update track info
    private func saveLyrics(_ lyrics: Lyrics) {
        guard let fileName = track?.defaultDisplayName else {
            return
        }

        lyrics.persistToFile(fileName)

        updateTrackInfo()
    }

    // MARK: - Notification Handlers

    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        updateTrackInfo()

        autoSearchLyrics()
    }

    private func trackInfoUpdated(_ notif: TrackInfoUpdatedNotification) {
        updateTrackInfo()
    }

    private func playbackStateChanged() {
        updateTrackInfo()
    }

    private func seekPerformed() {
        updateTrackInfo()
    }
}

extension LyricsWindowController: ColorSchemeObserver {
    func colorSchemeChanged() {
        applyColorScheme(systemColorScheme)
    }
}
