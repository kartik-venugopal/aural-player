//
//  PlayQueueViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 07/01/22.
//

import UIKit

class PlayQueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playQueueView: UITableView!
    
    let playQueue = playQueueDelegate
    let player = playbackDelegate
    
    private lazy var messenger: Messenger = Messenger(for: self, asyncNotificationQueue: .main)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        playQueueView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playQueue.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayQueueCell", for: indexPath)
        let trackIndex = indexPath.row
        
        guard let playQueueCell = cell as? PlayQueueCell, let track = playQueue[trackIndex] else {
            return cell
        }
        
        playQueueCell.lblIndex.text = "\(trackIndex + 1)"
        playQueueCell.lblTitle.text = track.displayName
        playQueueCell.lblDuration.text = ValueFormatter.formatSecondsToHMS(track.duration)
        
        return playQueueCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {65}
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: playQueueView)
        
        if let indexPath = playQueueView.indexPathForRow(at: touchPoint),
           let track = playQueue[indexPath.row] {
            
            player.play(track)
        }
    }
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        var indicesToReload: [Int] = []
        
        if let oldTrack = notif.beginTrack, let oldTrackIndex = playQueue.indexOfTrack(oldTrack) {
            indicesToReload.append(oldTrackIndex)
        }
        
        if let newTrack = notif.endTrack, let newTrackIndex = playQueue.indexOfTrack(newTrack) {
            indicesToReload.append(newTrackIndex)
        }
        
        playQueueView.reloadRows(at: indicesToReload.map {IndexPath(row: $0, section: 0)}, with: .fade)
    }
}

class PlayQueueCell: UITableViewCell {
    
    @IBOutlet var lblIndex: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDuration: UILabel!
}
