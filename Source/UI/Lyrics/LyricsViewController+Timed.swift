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
    
    func showTimedLyricsView() {
        
        tabView.selectTabViewItem(at: 1)

        curLine = nil
        tableView.reloadData()
        
        track != nil ? timer.startOrResume() : timer.pause()
        
        messenger.subscribeAsync(to: .Player.playbackStateChanged, handler: playbackStateChanged)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: seekPerformed)
    }
    
    func updateTimedLyricsText() {
        tableView.reloadData()
    }
    
    func dismissTimedLyricsView() {
        
        timer.pause()
        messenger.unsubscribe(from: .Player.playbackStateChanged)
        messenger.unsubscribe(from: .Player.seekPerformed)
    }
    
    func highlightCurrentLine() {
        
        guard let track, let timedLyrics else {return}
        
        let seekPos = playbackInfoDelegate.seekPosition.timeElapsed
        
        if let curLine, timedLyrics.isLineCurrent(atIndex: curLine, atPosition: seekPos, ofTrack: track) {
            
            // Current line is still current, do nothing.
            return
        }
        
        let newCurLine = timedLyrics.currentLine(at: seekPos, ofTrack: track)
        
        if newCurLine != self.curLine {
            
            // Try curLine + 1 (in most cases, playback proceeds sequentially, so this is the most likely line to match)
            let refreshIndices = [self.curLine, newCurLine].compactMap {$0}
            self.curLine = newCurLine
            tableView.reloadRows(refreshIndices)
            
            if let curLine {
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
