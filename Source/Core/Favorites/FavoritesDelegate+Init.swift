//
//  FavoritesDelegate+Init.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension FavoritesDelegate {
    
    func initialize(fromPersistentState persistentState: FavoritesPersistentState?) {
        
        guard let state = persistentState else {return}
        
        DispatchQueue.global(qos: .utility).async {
            
            for favTrack in state.favoriteTracks ?? [] {
                
                guard let trackFile = favTrack.trackFile else {continue}
                
                let track = Track(trackFile)
                self.favoriteTracks[trackFile] = FavoriteTrack(track: track)
                
                trackReader.loadPrimaryMetadataAsync(for: track, onQueue: TrackReader.mediumPriorityQueue)
            }
            
//            for favArtist in state.favoriteArtists?.compactMap({$0.groupName}) ?? [] {
//                self.favoriteArtists[favArtist] = FavoriteGroup(groupName: favArtist, groupType: .artist)
//            }
//            
//            for favAlbum in state.favoriteAlbums?.compactMap({$0.groupName}) ?? [] {
//                self.favoriteAlbums[favAlbum] = FavoriteGroup(groupName: favAlbum, groupType: .album)
//            }
//            
//            for favGenre in state.favoriteGenres?.compactMap({$0.groupName}) ?? [] {
//                self.favoriteGenres[favGenre] = FavoriteGroup(groupName: favGenre, groupType: .genre)
//            }
//            
//            for favDecade in state.favoriteDecades?.compactMap({$0.groupName}) ?? [] {
//                self.favoriteDecades[favDecade] = FavoriteGroup(groupName: favDecade, groupType: .decade)
//            }
            
            for favFolder in state.favoriteFolders?.compactMap({$0.folder}) ?? [] {
                self.favoriteFolders[favFolder] = FavoriteFolder(folder: favFolder)
            }
            
            for favPlaylistFile in state.favoritePlaylistFiles?.compactMap({$0.playlistFile}) ?? [] {
                self.favoritePlaylistFiles[favPlaylistFile] = FavoritePlaylistFile(playlistFile: favPlaylistFile)
            }
        }
    }
}
