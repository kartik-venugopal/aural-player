//
//  ViewController.swift
//  MediaKeyTapExample
//
//  Created by Nicholas Hurden on 22/02/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Cocoa
import MediaKeyTap

class ViewController: NSViewController {
    @IBOutlet weak var playPauseLabel: NSTextField!
    @IBOutlet weak var previousLabel: NSTextField!
    @IBOutlet weak var rewindLabel: NSTextField!
    @IBOutlet weak var nextLabel: NSTextField!
    @IBOutlet weak var fastForwardLabel: NSTextField!

    var mediaKeyTap: MediaKeyTap?

    override func viewDidLoad() {
        super.viewDidLoad()

        mediaKeyTap = MediaKeyTap(delegate: self, on: .keyDownAndUp)
        mediaKeyTap?.start()
    }

    func toggleLabel(_ label: NSTextField, enabled: Bool) {
        label.textColor = enabled ? NSColor.green : NSColor.textColor
    }
}

extension ViewController: MediaKeyTapDelegate {
    func handle(mediaKey: MediaKey, event: KeyEvent) {
        switch mediaKey {
        case .playPause:
            print("Play/pause pressed")
            toggleLabel(playPauseLabel, enabled: event.keyPressed)
        case .previous:
            print("Previous pressed")
            toggleLabel(previousLabel, enabled: event.keyPressed)
        case .rewind:
            print("Rewind pressed")
            toggleLabel(rewindLabel, enabled: event.keyPressed)
        case .next:
            print("Next pressed")
            toggleLabel(nextLabel, enabled: event.keyPressed)
        case .fastForward:
            print("Fast Forward pressed")
            toggleLabel(fastForwardLabel, enabled: event.keyPressed)
        }
    }
}
