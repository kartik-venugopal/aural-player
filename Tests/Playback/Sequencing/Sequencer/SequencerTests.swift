//
//  SequencerTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerTests: AuralTestCase {

    var sequencer: Sequencer!
    var playlist: Playlist!
    
    let artists: [String] = ["Conjure One", "Grimes", "Madonna", "Pink Floyd", "Dire Straits", "Ace of Base", "Delerium", "Blue Stone", "Jaia", "Paul Van Dyk"]
    
    let albums: [String] = ["Exilarch", "Halfaxa", "Vogue", "The Wall", "Brothers in Arms", "The Sign", "Music Box Opera", "Messages", "Mai Mai", "Reflections"]
    
    let genres: [String] = ["Electronica", "Pop", "Rock", "Dance", "International", "Jazz", "Ambient", "House", "Trance", "Techno", "Psybient", "PsyTrance", "Classical", "Opera"]
    
    func randomArtist() -> String {
        return artists[Int.random(in: 0..<artists.count)]
    }
    
    func randomAlbum() -> String {
        return albums[Int.random(in: 0..<albums.count)]
    }
    
    func randomGenre() -> String {
        return genres[Int.random(in: 0..<genres.count)]
    }
    
    var testPlaylistSizes: [Int] {
        
        var sizes: [Int] = [1, 2, 3, 5, 10, 50, 100, 500, 1000]
        
        if runLongRunningTests {sizes.append(10000)}
        
        let numRandomSizes = runLongRunningTests ? 100 : 10
        let maxSize = runLongRunningTests ? 10000 : 1000
        
        for _ in 1...numRandomSizes {
            sizes.append(Int.random(in: 5...maxSize))
        }
        
        return sizes
    }
    
    var repeatOneIdempotence_count: Int {
        return runLongRunningTests ? 10000 : 100
    }
    
    var sequenceRestart_count: Int {
        return runLongRunningTests ? 10 : 3
    }
    
    let repeatShufflePermutations: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] = {
        
        var array: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] = []
        
        for repeatMode in RepeatMode.allCases {
        
            for shuffleMode in ShuffleMode.allCases {
                
                // Repeat One / Shuffle On is not a valid permutation
                if (repeatMode, shuffleMode) != (.one, .on) {
                    array.append((repeatMode, shuffleMode))
                }
            }
        }
        
        return array
        
    }()

    override func setUp() {
        
        if sequencer == nil {
            
            let flatPlaylist = FlatPlaylist()
            let artistsPlaylist = GroupingPlaylist(.artists)
            let albumsPlaylist = GroupingPlaylist(.albums)
            let genresPlaylist = GroupingPlaylist(.genres)
            
            playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
            sequencer = Sequencer(playlist, .off, .off, .tracks)
        }
        
        playlist.clear()
    }
    
    func preTest(_ playlistType: PlaylistType, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        sequencer.playlistTypeChanged(playlistType)
        XCTAssertEqual(sequencer.playlistType, playlistType)
        
        _ = sequencer.setRepeatMode(repeatMode)
        let modes = sequencer.setShuffleMode(shuffleMode)
        
        XCTAssertEqual(modes.repeatMode, repeatMode)
        XCTAssertEqual(modes.shuffleMode, shuffleMode)
    }
    
    func createAndAddTrack(_ title: String, _ duration: Double, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        
        let track = Track(URL(fileURLWithPath: String(format: "/Dummy/%@.mp3", title)))
        track.setPrimaryMetadata(artist, title, album, genre, duration)
        
        _ = playlist.addTrack(track)
        
        return track
    }
    
    func createAndAddNTracks(_ numTracks: Int, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> [TrackAddResult] {
        
        let sizeBeforeAdd = playlist.size
        var tracks: [TrackAddResult] = []
        
        for counter in 1...numTracks {
            
            let title = "Track-" + String(sizeBeforeAdd + counter)
            let theArtist = artist ?? randomArtist()
            let theAlbum = album ?? randomAlbum()
            let theGenre = genre ?? randomGenre()
        
            let track = Track(URL(fileURLWithPath: String(format: "/Dummy/%@.mp3", title)))
            track.setPrimaryMetadata(theArtist, title, theAlbum, theGenre, Double.random(in: 60...600))
            
            tracks.append(playlist.addTrack(track)!)
        }
        
        XCTAssertEqual(playlist.size, sizeBeforeAdd + numTracks)
        
        return tracks
    }
    
    // A function that, given the size of the playlist, the index of the currently playing track (either within the playlist or a single group),
    // and the scope of playback ... produces a sequence of tracks (or nil) in the order that they should be
    // produced by calls to any of the iteration functions e.g. subsequent(), previous(), etc.
    //
    // This array is passed from a test function to a helper function to set the right expectations for the test.
    typealias ExpectedTracksFunction = (_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> (expectedTracks: [Track?], expectedIndices: [Int])
}
