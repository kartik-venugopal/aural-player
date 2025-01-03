////
////  LyricsWrappedView.swift
////  Aural
////
////  Created by tisfeng on 2024/12/2.
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
//
//import ComposableArchitecture
//import LyricsService
//import LyricsUI
//import LyricsXCore
//import MusicPlayer
//import SwiftUI
//
//struct LyricsWrappedView: View {
//
//    var track: MusicTrack?
//    var lyrics: Lyrics?
//    var elapsedTime: TimeInterval
//    var isPlaying: Bool
//    let onLyricsTap: ((Int, ScrollViewProxy) -> Void)?
//    let onLyricsUpdate: ((Lyrics) -> Void)?
//
//    public var viewStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>
//
//    @State private var isAutoScrollEnabled = true
//
//    @State private var searchLyricsWindowController: NSWindowController?
//
//    init(
//        track: MusicTrack? = nil,
//        lyrics: Lyrics? = nil,
//        elapsedTime: Double = 0,
//        isPlaying: Bool = true,
//        onLyricsTap: ((Int, ScrollViewProxy) -> Void)? = nil,
//        onLyricsUpdate: ((Lyrics) -> Void)? = nil
//    ) {
//        self.track = track
//        self.lyrics = lyrics
//        self.elapsedTime = elapsedTime
//        self.isPlaying = isPlaying
//        self.onLyricsTap = onLyricsTap
//        self.onLyricsUpdate = onLyricsUpdate
//        self.viewStore = createViewStore(
//            track: track,
//            lyrics: lyrics,
//            elapsedTime: elapsedTime,
//            isPlaying: isPlaying
//        )
//    }
//
//    var body: some View {
//        if #available(macOS 13.0, *) {
//            LyricsView(
//                isAutoScrollEnabled: $isAutoScrollEnabled,
//                showTranslation: preferences.viewPreferences.showLyricsTranslation.value
//            ) { index, proxy in
//                let position = self.lyrics?[index].position ?? 0
//                seekTo(position: position, isPlaying: isPlaying)
//
//                withAnimation(.easeInOut) {
//                    proxy.scrollTo(index, anchor: .center)
//                }
//
//                onLyricsTap?(index, proxy)
//            }
//            .environmentObject(viewStore)
//            .padding()
//            .frame(minWidth: 300, minHeight: 80)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .contextMenu {
//                Button(action: {
//                    showSearchLyricsWindow()
//                }) {
//                    Text("Search Lyrics")
//                }
//            }
//        } else {
//            Text("Lyrics only available on macOS 13.0 or later")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    /// Seek to position.
//    public func seekTo(position: TimeInterval, isPlaying: Bool) {
//        let playbackState = createPlaybackState(elapsedTime: position, isPlaying: isPlaying)
//        let progressingAction = LyricsProgressingAction.playbackStateUpdated(playbackState)
//        viewStore.send(.progressingAction(progressingAction))
//    }
//
//    /// Show search lyrics window
//    func showSearchLyricsWindow() {
//        // Close previous window if exists
//        searchLyricsWindowController?.close()
//
//        let windowController = NSWindowController(window: nil)
//        let window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 600),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable],
//            backing: .buffered,
//            defer: false
//        )
//        window.title = "Search Lyrics"
//        window.center()
//
//        let searchService = LyricsSearchService(searchText: track?.searchQuery ?? "")
//
//        if #available(macOS 12.0, *) {
//            let contentView = LyricsSearchView(searchService: searchService) { lyrics in
//                self.onLyricsUpdate?(lyrics)
//                self.searchLyricsWindowController?.close()
//                self.searchLyricsWindowController = nil
//            }
//            window.contentView = NSHostingView(rootView: contentView)
//        }
//
//        windowController.window = window
//        searchLyricsWindowController = windowController
//        windowController.showWindow(nil)
//    }
//}
