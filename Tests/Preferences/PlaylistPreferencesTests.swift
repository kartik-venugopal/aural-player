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
        
        for _ in 1...100 {
            
            resetDefaults()
            
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
        
        for _ in 1...100 {
            
            resetDefaults()
            
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
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...100 {
            
            resetDefaults()
            doTestPersist(prefs: randomPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            let serializedPrefs = randomPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: .standard)
            
            let deserializedPrefs = PlaylistPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: .standard)
        }
    }
    
    private func doTestPersist(prefs: PlaylistPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: PlaylistPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: PlaylistPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_playlistOnStartup), prefs.playlistOnStartup.rawValue)
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_playlistFile), prefs.playlistFile?.path)
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_tracksFolder), prefs.tracksFolder?.path)
        
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_viewOnStartupOption), prefs.viewOnStartup.option.rawValue)
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_viewOnStartupViewName), prefs.viewOnStartup.viewName)
        
        XCTAssertEqual(userDefs.bool(forKey: PlaylistPreferences.key_showNewTrackInPlaylist), prefs.showNewTrackInPlaylist)
        XCTAssertEqual(userDefs.bool(forKey: PlaylistPreferences.key_showChaptersList), prefs.showChaptersList)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> PlaylistPreferences {
        
        let prefs = PlaylistPreferences([:])
        
        let playlistStartupOptions = randomPlaylistStartupOptions()
        
        prefs.playlistOnStartup = playlistStartupOptions.option
        prefs.playlistFile = playlistStartupOptions.playlistFile
        prefs.tracksFolder = playlistStartupOptions.tracksFolder
        
        prefs.viewOnStartup = randomPlaylistViewOnStartup()
        
        prefs.showNewTrackInPlaylist = .random()
        prefs.showChaptersList = .random()
        
        return prefs
    }
    
    private func randomPlaylistStartupOptions() -> (option: PlaylistStartupOptions, playlistFile: URL?, tracksFolder: URL?) {
        
        let playlistOnStartup: PlaylistStartupOptions = .randomCase()
        
        var playlistFile: URL? = nil
        var tracksFolder: URL? = nil
        
        switch playlistOnStartup {
        
        case .loadFile:
            
            playlistFile = URL(fileURLWithPath: randomPlaylistFile())
            
        case .loadFolder:
            
            tracksFolder = URL(fileURLWithPath: randomFolder())
            
        default:
            
            playlistFile = nil
            tracksFolder = nil
        }
        
        return (playlistOnStartup, playlistFile, tracksFolder)
    }
    
    private func randomNillablePlaylistStartupOptions() -> PlaylistStartupOptions? {
        randomNillableValue {.randomCase()}
    }
    
    private func randomNillablePlaylistFile() -> URL? {
        randomNillableValue {URL(fileURLWithPath: randomPlaylistFile())}
    }
    
    private func randomNillableTracksFolder() -> URL? {
        randomNillableValue {URL(fileURLWithPath: randomFolder())}
    }
    
    private static let playlistViewNames: [String] = ["Tracks", "Artists", "Albums", "Genres"]
    
    private func randomPlaylistViewOnStartup() -> PlaylistViewOnStartup {
        
        let viewOnStartup = PlaylistViewOnStartup()
        
        viewOnStartup.option = .randomCase()
        viewOnStartup.viewName = Self.playlistViewNames.randomElement()
        
        return viewOnStartup
    }
    
    private func randomNillablePlaylistViewOnStartup() -> PlaylistViewOnStartup? {
        randomNillableValue {self.randomPlaylistViewOnStartup()}
    }
}
