//
// LyricsViewController+Timed.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension LyricsViewController {
    
    var fileOpenDialog: NSOpenPanel {DialogsAndAlerts.openLyricsFileDialog}
    
    func showTimedLyricsView() {
        
        tabView.selectTabViewItem(at: 1)
        
        curLine = nil
        tableView.reloadData()
        
        track != nil ? timer.startOrResume() : timer.pause()
        
        messenger.subscribeAsync(to: .Player.playbackStateChanged, handler: playbackStateChanged)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: seekPerformed)
    }
    
    @IBAction func loadLyricsButtonAction(_ sender: NSButton) {
        
        if fileOpenDialog.runModal() == .OK, let lyricsFile = fileOpenDialog.url {
            loadLyrics(fromFile: lyricsFile)
        }
    }
    
    @IBAction func searchForLyricsOnlineButtonAction(_ sender: NSButton) {
        
        // TODO:
    }
    
    func loadLyrics(fromFile lyricsFile: URL) {
        
        guard let track, trackReader.loadTimedLyricsFromFile(at: lyricsFile, for: track) else {
            
            NSAlert.showError(withTitle: "Lyrics not loaded", andText: "Failed to load synced lyrics from file: '\(lyricsFile.lastPathComponent)'")
            return
        }
        
        self.timedLyrics = track.externalTimedLyrics
        
        showTimedLyricsView()
    }
    
    func updateTimedLyricsText() {
        tableView.reloadData()
    }
    
    func dismissTimedLyricsView() {
        
        timer.pause()
        messenger.unsubscribe(from: .Player.playbackStateChanged)
        messenger.unsubscribe(from: .Player.seekPerformed)
    }
    
    private var isAutoScrollEnabled: Bool {
        preferences.metadataPreferences.lyrics.enableAutoScroll.value
    }
    
    func highlightCurrentLine() {
        
        guard let timedLyrics else {return}
        
        let seekPos = playbackInfoDelegate.seekPosition.timeElapsed
        
        if let curLine, timedLyrics.lines[curLine].isCurrent(atPosition: seekPos) {
            
            // Current line is still current, do nothing.
            return
        }
        
        let newCurLine = timedLyrics.currentLine(at: seekPos)
        
        if newCurLine != self.curLine {
            
            // Try curLine + 1 (in most cases, playback proceeds sequentially, so this is the most likely line to match)
            let refreshIndices = [self.curLine, newCurLine].compactMap {$0}
            self.curLine = newCurLine
            tableView.reloadRows(refreshIndices)
            
            if isAutoScrollEnabled, let curLine {
                tableView.scrollRowToVisible(curLine)
            }
        }
    }
    
    func playbackStateChanged() {
        player.state == .playing ? timer.startOrResume() : timer.pause()
    }

    func seekPerformed() {
        highlightCurrentLine()
    }
}
