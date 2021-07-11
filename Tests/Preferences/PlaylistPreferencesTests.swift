//
//  PlaylistPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaylistPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Playlist
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   playlistOnStartup: nil,
                   playlistFile: nil,
                   tracksFolder: nil,
                   viewOnStartup: nil,
                   showNewTrackInPlaylist: nil,
                   showChaptersList: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       playlistOnStartup: randomNillablePlaylistStartupOptions(),
                       playlistFile: randomNillablePlaylistFile(),
                       tracksFolder: randomNillableTracksFolder(),
                       viewOnStartup: randomNillablePlaylistViewOnStartup(),
                       showNewTrackInPlaylist: randomNillableBool(),
                       showChaptersList: randomNillableBool())
        }
    }
    
    func testInit() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let playlistStartupOptions = randomPlaylistStartupOptions()
            
            doTestInit(userDefs: UserDefaults(),
                       playlistOnStartup: playlistStartupOptions.option,
                       playlistFile: playlistStartupOptions.playlistFile,
                       tracksFolder: playlistStartupOptions.tracksFolder,
                       viewOnStartup: randomPlaylistViewOnStartup(),
                       showNewTrackInPlaylist: .random(),
                       showChaptersList: .random())
        }
    }
    
    func testInit_loadPlaylistFileOption() {
        
        doTestInit(userDefs: UserDefaults(),
                   playlistOnStartup: .loadFile,
                   playlistFile: URL(fileURLWithPath: randomPlaylistFile()),
                   tracksFolder: nil,
                   viewOnStartup: randomPlaylistViewOnStartup(),
                   showNewTrackInPlaylist: .random(),
                   showChaptersList: .random())
    }
    
    func testInit_loadPlaylistFileOption_noFileSpecified() {
        
        doTestInit(userDefs: UserDefaults(),
                   playlistOnStartup: .loadFile,
                   playlistFile: nil,
                   tracksFolder: nil,
                   viewOnStartup: randomPlaylistViewOnStartup(),
                   showNewTrackInPlaylist: .random(),
                   showChaptersList: .random())
    }
    
    func testInit_loadTracksFolderOption() {
        
        doTestInit(userDefs: UserDefaults(),
                   playlistOnStartup: .loadFolder,
                   playlistFile: nil,
                   tracksFolder: URL(fileURLWithPath: randomFolder()),
                   viewOnStartup: randomPlaylistViewOnStartup(),
                   showNewTrackInPlaylist: .random(),
                   showChaptersList: .random())
    }
    
    func testInit_loadTracksFolderOption_noFolderSpecified() {
        
        doTestInit(userDefs: UserDefaults(),
                   playlistOnStartup: .loadFolder,
                   playlistFile: nil,
                   tracksFolder: nil,
                   viewOnStartup: randomPlaylistViewOnStartup(),
                   showNewTrackInPlaylist: .random(),
                   showChaptersList: .random())
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            playlistOnStartup: PlaylistStartupOptions?,
                            playlistFile: URL?,
                            tracksFolder: URL?,
                            viewOnStartup: PlaylistViewOnStartup?,
                            showNewTrackInPlaylist: Bool?,
                            showChaptersList: Bool?) {
        
        userDefs[PlaylistPreferences.key_viewOnStartupOption] = viewOnStartup?.option.rawValue
        userDefs[PlaylistPreferences.key_viewOnStartupViewName] = viewOnStartup?.viewName
        
        userDefs[PlaylistPreferences.key_playlistOnStartup] = playlistOnStartup?.rawValue
        userDefs[PlaylistPreferences.key_playlistFile] = playlistFile?.path
        userDefs[PlaylistPreferences.key_tracksFolder] = tracksFolder?.path
        
        userDefs[PlaylistPreferences.key_showNewTrackInPlaylist] = showNewTrackInPlaylist
        userDefs[PlaylistPreferences.key_showChaptersList] = showChaptersList
        
        let prefs = PlaylistPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.viewOnStartup.option, viewOnStartup?.option ?? Defaults.viewOnStartup.option)
        XCTAssertEqual(prefs.viewOnStartup.viewName, viewOnStartup?.viewName ?? Defaults.viewOnStartup.viewName)
        
        var expectedPlaylistOnStartup: PlaylistStartupOptions = playlistOnStartup ?? Defaults.playlistOnStartup
        var expectedPlaylistFile: URL? = playlistFile ?? Defaults.playlistFile
        var expectedTracksFolder: URL? = tracksFolder ?? Defaults.tracksFolder
        
        if let thePlaylistOnStartup = playlistOnStartup {
            
            if thePlaylistOnStartup == .loadFile, playlistFile == nil {
                
                expectedPlaylistOnStartup = Defaults.playlistOnStartup
                expectedPlaylistFile = Defaults.playlistFile
                
            } else if thePlaylistOnStartup == .loadFolder, tracksFolder == nil {
                
                expectedPlaylistOnStartup = Defaults.playlistOnStartup
                expectedTracksFolder = Defaults.tracksFolder
            }
        }
        
        XCTAssertEqual(prefs.playlistOnStartup, expectedPlaylistOnStartup)
        XCTAssertEqual(prefs.playlistFile, expectedPlaylistFile)
        XCTAssertEqual(prefs.tracksFolder, expectedTracksFolder)
        
        XCTAssertEqual(prefs.showNewTrackInPlaylist, showNewTrackInPlaylist ?? Defaults.showNewTrackInPlaylist)
        XCTAssertEqual(prefs.showChaptersList, showChaptersList ?? Defaults.showChaptersList)
    }
    
    func populateWithNilPlaylistPreferences(userDefs: UserDefaults) {
        
        userDefs[PlaylistPreferences.key_viewOnStartupOption] = nil
        userDefs[PlaylistPreferences.key_viewOnStartupViewName] = nil
        
        userDefs[PlaylistPreferences.key_playlistOnStartup] = nil
        userDefs[PlaylistPreferences.key_playlistFile] = nil
        userDefs[PlaylistPreferences.key_tracksFolder] = nil
        
        userDefs[PlaylistPreferences.key_showNewTrackInPlaylist] = nil
        userDefs[PlaylistPreferences.key_showChaptersList] = nil
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            doTestPersist(prefs: randomPlaylistPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomPlaylistPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = PlaylistPreferences(defaults.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: PlaylistPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: PlaylistPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
