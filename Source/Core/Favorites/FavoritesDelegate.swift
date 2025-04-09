//
//  FavoritesDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import OrderedCollections

///
/// A delegate allowing access to the list of user-defined favorites.
///
/// Acts as a middleman between the UI and the Favorites list,
/// providing a simplified interface / facade for the UI layer to manipulate the Favorites list.
///
/// - SeeAlso: `Favorite`
///
class FavoritesDelegate: FavoritesDelegateProtocol {
    
    var favoriteTracks: OrderedDictionary<URL, FavoriteTrack>
    
//    var favoriteArtists: OrderedDictionary<String, FavoriteGroup>
//    var favoriteAlbums: OrderedDictionary<String, FavoriteGroup>
//    var favoriteGenres: OrderedDictionary<String, FavoriteGroup>
//    var favoriteDecades: OrderedDictionary<String, FavoriteGroup>
    
    var favoriteFolders: OrderedDictionary<URL, FavoriteFolder>
    var favoritePlaylistFiles: OrderedDictionary<URL, FavoritePlaylistFile>
    
    private let playQueue: PlayQueueDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(_ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.player = player
        self.playQueue = playQueue
        
        self.favoriteTracks = OrderedDictionary()
//        self.favoriteArtists = OrderedDictionary()
//        self.favoriteAlbums = OrderedDictionary()
//        self.favoriteGenres = OrderedDictionary()
//        self.favoriteDecades = OrderedDictionary()
        self.favoriteFolders = OrderedDictionary()
        self.favoritePlaylistFiles = OrderedDictionary()
    }
    
    var hasAnyFavorites: Bool {
//        favoriteTracks.values.isNonEmpty || favoriteArtists.values.isNonEmpty || f/*avoriteAlbums.values.isNonEmpty || favoriteGenres.values.isNonEmpty || favoriteDecades.values.isNonEmpty || favoriteFolders.values.isNonEmpty*/
        
        favoriteTracks.values.isNonEmpty || favoriteFolders.values.isNonEmpty
    }
    
    var allFavoriteTracks: [FavoriteTrack] {
        Array(favoriteTracks.values)
    }
    
    func favoriteTrack(atChronologicalIndex index: Int) -> FavoriteTrack? {
        
        if favoriteTracks.indices.contains(index) {
        
            // Invert the index
            return favoriteTracks.values[favoriteTracks.count - index - 1]
        }
        
        return nil
    }
    
    var numberOfFavoriteTracks: Int {
        favoriteTracks.count
    }
    
//    var allFavoriteArtists: [FavoriteGroup] {
//        Array(favoriteArtists.values)
//    }
//    
//    var numberOfFavoriteArtists: Int {
//        favoriteArtists.count
//    }
//    
//    func favoriteArtist(atChronologicalIndex index: Int) -> FavoriteGroup? {
//        
//        if favoriteArtists.indices.contains(index) {
//            return favoriteArtists.values[favoriteArtists.count - index - 1]
//        }
//        
//        return nil
//    }
//    
//    var allFavoriteAlbums: [FavoriteGroup] {
//        Array(favoriteAlbums.values)
//    }
//    
//    var numberOfFavoriteAlbums: Int {
//        favoriteAlbums.count
//    }
//    
//    func favoriteAlbum(atChronologicalIndex index: Int) -> FavoriteGroup? {
//        
//        if favoriteAlbums.indices.contains(index) {
//            return favoriteAlbums.values[favoriteAlbums.count - index - 1]
//        }
//        
//        return nil
//    }
//    
//    var allFavoriteGenres: [FavoriteGroup] {
//        Array(favoriteGenres.values)
//    }
//    
//    var numberOfFavoriteGenres: Int {
//        favoriteGenres.count
//    }
//    
//    func favoriteGenre(atChronologicalIndex index: Int) -> FavoriteGroup? {
//        
//        if favoriteGenres.indices.contains(index) {
//            return favoriteGenres.values[favoriteGenres.count - index - 1]
//        }
//        
//        return nil
//    }
//    
//    var allFavoriteDecades: [FavoriteGroup] {
//        Array(favoriteDecades.values)
//    }
//    
//    var numberOfFavoriteDecades: Int {
//        favoriteDecades.count
//    }
//    
//    func favoriteDecade(atChronologicalIndex index: Int) -> FavoriteGroup? {
//        
//        if favoriteDecades.indices.contains(index) {
//            return favoriteDecades.values[favoriteDecades.count - index - 1]
//        }
//        
//        return nil
//    }
    
    var allFavoriteFolders: [FavoriteFolder] {
        Array(favoriteFolders.values)
    }
    
    var numberOfFavoriteFolders: Int {
        favoriteFolders.count
    }
    
    func favoriteFolder(atChronologicalIndex index: Int) -> FavoriteFolder? {
        
        if favoriteFolders.indices.contains(index) {
            return favoriteFolders.values[favoriteFolders.count - index - 1]
        }
        
        return nil
    }
    
    var allFavoritePlaylistFiles: [FavoritePlaylistFile] {
        Array(favoritePlaylistFiles.values)
    }
    
    var numberOfFavoritePlaylistFiles: Int {
        favoritePlaylistFiles.count
    }
    
    func favoritePlaylistFile(atChronologicalIndex index: Int) -> FavoritePlaylistFile? {
        
        if favoritePlaylistFiles.indices.contains(index) {
            return favoritePlaylistFiles.values[favoritePlaylistFiles.count - index - 1]
        }
        
        return nil
    }
    
    var artistsFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.artist})
    }
    
    var albumsFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.album})
    }
    
    var genresFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.genre})
    }
    
    var decadesFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.decade})
    }
    
    func addFavorite(track: Track) {
        
        let favorite = FavoriteTrack(track: track)
        favoriteTracks[track.file] = favorite
        Messenger.publish(.Favorites.itemAdded, payload: favorite)
    }
    
//    func addFavorite(artist: String) {
//        
//        let favorite = FavoriteGroup(groupName: artist, groupType: .artist)
//        favoriteArtists[artist] = favorite
//        Messenger.publish(.Favorites.itemAdded, payload: favorite)
//    }
//    
//    func addFavorite(album: String) {
//        
//        let favorite = FavoriteGroup(groupName: album, groupType: .album)
//        favoriteAlbums[album] = favorite
//        Messenger.publish(.Favorites.itemAdded, payload: favorite)
//    }
//    
//    func addFavorite(genre: String) {
//        
//        let favorite = FavoriteGroup(groupName: genre, groupType: .genre)
//        favoriteGenres[genre] = favorite
//        Messenger.publish(.Favorites.itemAdded, payload: favorite)
//    }
//
//    func addFavorite(decade: String) {
//        
//        let favorite = FavoriteGroup(groupName: decade, groupType: .decade)
//        favoriteDecades[decade] = favorite
//        Messenger.publish(.Favorites.itemAdded, payload: favorite)
//    }
    
    func addFavorite(folder: URL) {
     
        let favorite = FavoriteFolder(folder: folder)
        favoriteFolders[folder] = favorite
        Messenger.publish(.Favorites.itemAdded, payload: favorite)
    }
    
    func addFavorite(playlistFile: URL) {
        
        let favorite = FavoritePlaylistFile(playlistFile: playlistFile)
        favoritePlaylistFiles[playlistFile] = favorite
        Messenger.publish(.Favorites.itemAdded, payload: favorite)
    }
    
    func removeFavorite(_ favorite: Favorite) {
        
        if let favTrack = favorite as? FavoriteTrack {
            removeFavorite(track: favTrack.track)
            
//        } else if let favGroup = favorite as? FavoriteGroup {
//            
//            switch favGroup.groupType {
//                
//            case .artist:
//                removeFavorite(artist: favGroup.groupName)
//                
//            case .album:
//                removeFavorite(album: favGroup.groupName)
//                
//            case .genre:
//                removeFavorite(genre: favGroup.groupName)
//                
//            case .decade:
//                removeFavorite(decade: favGroup.groupName)
//                
//            default:
//                return
//            }
            
        } else if let favFolder = favorite as? FavoriteFolder {
            removeFavorite(folder: favFolder.folder)
            
        } else if let favPlaylistFile = favorite as? FavoritePlaylistFile {
            removeFavorite(playlistFile: favPlaylistFile.playlistFile)
        }
    }
    
    func removeFavorite(track: Track) {
        
        if let removedFav = favoriteTracks.removeValue(forKey: track.file) {
            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
//    func removeFavorite(artist: String) {
//        
//        if let removedFav = favoriteArtists.removeValue(forKey: artist) {
//            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
//        }
//    }
//    
//    func removeFavorite(album: String) {
//        
//        if let removedFav = favoriteAlbums.removeValue(forKey: album) {
//            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
//        }
//    }
//    
//    func removeFavorite(genre: String) {
//        
//        if let removedFav = favoriteGenres.removeValue(forKey: genre) {
//            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
//        }
//    }
//    
//    func removeFavorite(decade: String) {
//        
//        if let removedFav = favoriteDecades.removeValue(forKey: decade) {
//            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
//        }
//    }
    
    func removeFavorite(folder: URL) {
        
        if let removedFav = favoriteFolders.removeValue(forKey: folder) {
            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(playlistFile: URL) {
        
        if let removedFav = favoritePlaylistFiles.removeValue(forKey: playlistFile) {
            Messenger.publish(.Favorites.itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func favoriteExists(track: Track) -> Bool {
        favoriteTracks[track.file] != nil
    }
    
//    func favoriteExists(artist: String) -> Bool {
//        favoriteArtists[artist] != nil
//    }
//    
//    func favoriteExists(album: String) -> Bool {
//        favoriteAlbums[album] != nil
//    }
//    
//    func favoriteExists(genre: String) -> Bool {
//        favoriteGenres[genre] != nil
//    }
//    
//    func favoriteExists(decade: String) -> Bool {
//        favoriteDecades[decade] != nil
//    }
    
    func favoriteExists(playlistFile: URL) -> Bool {
        favoritePlaylistFiles[playlistFile] != nil
    }
    
    func favoriteExists(folder: URL) -> Bool {
        favoriteFolders[folder] != nil
    }
    
    func playFavorite(_ favorite: Favorite) {

        if let favTrack = favorite as? FavoriteTrack {
            playQueueDelegate.enqueueToPlayNow(tracks: [favTrack.track], clearQueue: false)
            
//        } else if let favGroup = favorite as? FavoriteGroup,
//                  let group = libraryDelegate.findGroup(named: favGroup.groupName, ofType: favGroup.groupType) {
//         
//            playQueueDelegate.enqueueToPlayNow(group: group, clearQueue: false)
            
        } else if let favFolder = favorite as? FavoriteFolder {
            
            // Recursively get all tracks, then add them to the PQ before playing
            
//            if let folder = libraryDelegate.findFileSystemFolder(atLocation: favFolder.folder) {
//                playQueueDelegate.enqueueToPlayNow(fileSystemItems: [folder], clearQueue: false)
//                
//            } else {
                playQueueDelegate.loadTracks(from: [favFolder.folder], params: .init(autoplayFirstAddedTrack: true))
//            }
            
        } 
//        else if let favPlaylistFile = favorite as? FavoritePlaylistFile {
//            
//            if let importedPlaylist = libraryDelegate.findImportedPlaylist(atLocation: favPlaylistFile.playlistFile) {
//                playQueueDelegate.enqueueToPlayNow(playlistFile: importedPlaylist, clearQueue: false)
//                
//            } else {
//                playQueueDelegate.loadTracks(from: [favPlaylistFile.playlistFile], params: .init(autoplay: true))
//            }
//        }
    }
    
    func enqueueFavorite(_ favorite: Favorite) {
        
        if let favTrack = favorite as? FavoriteTrack {
            playQueueDelegate.enqueueToPlayLater(tracks: [favTrack.track])
            
//        } else if let favGroup = favorite as? FavoriteGroup,
//                  let group = libraryDelegate.findGroup(named: favGroup.groupName, ofType: favGroup.groupType) {
//         
//            playQueueDelegate.enqueueToPlayLater(group: group)
            
        } else if let favFolder = favorite as? FavoriteFolder {
            
            // Recursively get all tracks, then add them to the PQ before playing
            
//            if let folder = libraryDelegate.findFileSystemFolder(atLocation: favFolder.folder) {
//                playQueueDelegate.enqueueToPlayLater(fileSystemItems: [folder])
//                
//            } else {
                playQueueDelegate.loadTracks(from: [favFolder.folder], params: .init(autoplayFirstAddedTrack: false))
//            }
            
        } else if let favPlaylistFile = favorite as? FavoritePlaylistFile {
            
//            if let importedPlaylist = libraryDelegate.findImportedPlaylist(atLocation: favPlaylistFile.playlistFile) {
//                playQueueDelegate.enqueueToPlayLater(playlistFile: importedPlaylist)
//                
//            } else {
                playQueueDelegate.loadTracks(from: [favPlaylistFile.playlistFile], params: .init(autoplayFirstAddedTrack: false))
//            }
        }
    }
    
    var persistentState: FavoritesPersistentState {
        
//        FavoritesPersistentState(favoriteTracks: self.allFavoriteTracks.map {FavoriteTrackPersistentState(favorite: $0)},
//                                 favoriteArtists: self.allFavoriteArtists.map {FavoriteGroupPersistentState(favorite: $0)},
//                                 favoriteAlbums: self.allFavoriteAlbums.map {FavoriteGroupPersistentState(favorite: $0)},
//                                 favoriteGenres: self.allFavoriteGenres.map {FavoriteGroupPersistentState(favorite: $0)},
//                                 favoriteDecades: self.allFavoriteDecades.map {FavoriteGroupPersistentState(favorite: $0)},
//                                 favoriteFolders: self.allFavoriteFolders.map {FavoriteFolderPersistentState(favorite: $0)},
//                                 favoritePlaylistFiles: self.allFavoritePlaylistFiles.map {FavoritePlaylistFilePersistentState(favorite: $0)})
        
        FavoritesPersistentState(favoriteTracks: self.allFavoriteTracks.map {FavoriteTrackPersistentState(favorite: $0)},
                                 favoriteFolders: self.allFavoriteFolders.map {FavoriteFolderPersistentState(favorite: $0)})
    }
}

extension FavoritesDelegate: TrackRegistryClient {
    
    func updateWithTracksIfPresent(_ tracks: any  Sequence<Track>) {
        
        for track in tracks {
            
            if let favorite = favoriteTracks[track.file] {
                favorite.track = track
            }
        }
    }
}
