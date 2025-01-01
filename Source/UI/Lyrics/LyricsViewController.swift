//
// LyricsViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit
import LyricsCore

class LyricsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Lyrics"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var track: Track?
    var lyrics: Lyrics?
    var curLine: Int?
    
    private lazy var messenger = Messenger(for: self)
    
    lazy var timer: RepeatingTaskExecutor = RepeatingTaskExecutor(intervalMillis: (1000 / (100 * audioGraphDelegate.timeStretchUnit.effectiveRate)).roundedInt,
                                                                      task: {[weak self] in
        self?.highlightCurrentLine()},
                                                                      queue: .main)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        fontSchemeChanged()
        colorSchemeChanged()
        changeCornerRadius(playerUIState.cornerRadius)
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        updateForTrack(playbackInfoDelegate.playingTrack)
    }
    
    private func updateForTrack(_ track: Track?) {
        
        self.track = track
        self.lyrics = track?.fetchLocalLyrics()
        
        updateLyricsText()
        track != nil ? timer.startOrResume() : timer.pause()
    }
    
    private func updateLyricsText() {
        
        tableView.reloadData()
        curLine = nil
    }
    
    private func highlightCurrentLine() {
        
        guard let lyrics else {return}
        
        let seekPos = playbackInfoDelegate.seekPosition.timeElapsed
        
        if let curLine, lyrics.lines[curLine].isCurrent(atPosition: seekPos) {
            
            // Current line is still current, do nothing.
            return
        }
        
        let newCurLine = lyrics.currentLine(at: seekPos)
        
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
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        updateForTrack(notif.endTrack)
    }
    
    func changeCornerRadius(_ radius: CGFloat) {
        view.layer?.cornerRadius = radius
    }
}

extension LyricsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        updateLyricsText()
    }
}

extension LyricsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {

        view.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        updateLyricsText()
    }
}

extension Lyrics {
    
    func currentLine(at position: TimeInterval) -> Int? {
        
        var left = 0
        var right = lines.count - 1

        while left <= right {
            
            let mid = (left + right) / 2
            let candidate: LyricsLine = lines[mid]
            
            switch candidate.relativePosition(to: position) {
                
            case .match:
                return mid
                
            case .left:
                left = mid + 1
                
            case .right:
                right = mid - 1
            }
        }
        
        return nil
    }
}

extension LyricsLine {
    
    func relativePosition(to target: TimeInterval) -> LyricsLineRelativePosition {
        
        if target < self.position {
            return .right
        }
        
        if target > self.maxPosition {
            return .left
        }
        
        return .match
    }
    
    func isCurrent(atPosition target: TimeInterval) -> Bool {
        target >= self.position && target <= self.maxPosition
    }
}

enum LyricsLineRelativePosition {
    
    case match
    case left
    case right
}
