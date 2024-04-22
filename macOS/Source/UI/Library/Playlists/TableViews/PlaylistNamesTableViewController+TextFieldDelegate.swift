////
////  PlaylistNamesTableViewController+TextFieldDelegate.swift
////  Aural
////
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Cocoa
//
//extension PlaylistNamesTableViewController: NSTextFieldDelegate {
//    
//    func controlTextDidEndEditing(_ obj: Notification) {
//        
//        guard let editedTextField = obj.object as? NSTextField else {return}
//        
//        let rowIndex = tableView.selectedRow
//        let playlist = playlistsManager.userDefinedObjects[rowIndex]
//        
//        let oldPlaylistName = playlist.name
//        let newPlaylistName = editedTextField.stringValue
//        
//        // No change in playlist name. Nothing to be done.
//        if newPlaylistName == oldPlaylistName {return}
//        
//        editedTextField.textColor = .defaultSelectedLightTextColor
//        
//        // If new name is empty or a playlist with the new name exists, revert to old value.
//        if newPlaylistName.isEmptyAfterTrimming {
//            
//            editedTextField.stringValue = playlist.name
//            
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Playlist name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
//            
//        } else if playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
//            
//            editedTextField.stringValue = playlist.name
//            
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Another playlist with that name already exists.", "Please type a unique name.").showModal()
//            
//        } else {
//            
//            playlistsManager.renameObject(named: oldPlaylistName, to: newPlaylistName)
////            playlistViewController.playlist = playlist
//        }
//    }
//}
