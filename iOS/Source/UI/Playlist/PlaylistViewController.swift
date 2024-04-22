//
//  PlaylistViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 07/01/22.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playlistView: UITableView!
    
    let playlist = objectGraph.playlistDelegate
    let player = objectGraph.playbackDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        playlistView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlist.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        
        guard let playlistCell = cell as? PlaylistCell else {
            return cell
        }
        
        let trackIndex = indexPath.row
        
        playlistCell.lblIndex.text = "\(trackIndex + 1)"
        playlistCell.lblTitle.text = playlist.trackAtIndex(trackIndex)?.displayName ?? "<None>"
        
        return playlistCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {65}
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: playlistView)
        
        if let indexPath = playlistView.indexPathForRow(at: touchPoint),
           let track = playlist.trackAtIndex(indexPath.row) {
            
            player.play(track)
        }
    }
}

class PlaylistCell: UITableViewCell {
    
    @IBOutlet var lblIndex: UILabel!
    @IBOutlet var lblTitle: UILabel!
}
