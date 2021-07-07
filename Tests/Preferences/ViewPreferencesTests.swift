//
//  ViewPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class ViewPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.View
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   appModeOnStartup: nil,
                   layoutOnStartup: nil,
                   snapToWindows: nil,
                   snapToScreen: nil,
                   windowGap: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       appModeOnStartup: randomNillableAppModeOnStartup(),
                       layoutOnStartup: randomNillableLayoutOnStartup(),
                       snapToWindows: randomNillableBool(),
                       snapToScreen: randomNillableBool(),
                       windowGap: randomNillableWindowGap())
        }
    }
    
    func testInit_preferredAppMode() {
        doTestInit_withPreferredAppMode(name: randomAppModeName())
    }
    
    func testInit_preferredAppMode_noModeNameSpecified() {
        doTestInit_withPreferredAppMode(name: nil)
    }
    
    private func doTestInit_withPreferredAppMode(name: String?) {
        
        let appMode = AppModeOnStartup()
        appMode.option = .specific
        appMode.modeName = name
        
        doTestInit(userDefs: UserDefaults(),
                   appModeOnStartup: appMode,
                   layoutOnStartup: randomLayoutOnStartup(),
                   snapToWindows: .random(),
                   snapToScreen: .random(),
                   windowGap: randomWindowGap())
    }
    
    func testInit_preferredLayout() {
        doTestInit_withPreferredLayout(name: randomLayoutName())
    }
    
    func testInit_preferredLayout_noLayoutNameSpecified() {
        doTestInit_withPreferredLayout(name: nil)
    }
    
    private func doTestInit_withPreferredLayout(name: String?) {
        
        let layout = LayoutOnStartup()
        layout.option = .specific
        layout.layoutName = name
        
        doTestInit(userDefs: UserDefaults(),
                   appModeOnStartup: randomAppModeOnStartup(),
                   layoutOnStartup: layout,
                   snapToWindows: .random(),
                   snapToScreen: .random(),
                   windowGap: randomWindowGap())
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       appModeOnStartup: randomAppModeOnStartup(),
                       layoutOnStartup: randomLayoutOnStartup(),
                       snapToWindows: .random(),
                       snapToScreen: .random(),
                       windowGap: randomWindowGap())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            appModeOnStartup: AppModeOnStartup?,
                            layoutOnStartup: LayoutOnStartup?,
                            snapToWindows: Bool?,
                            snapToScreen: Bool?,
                            windowGap: Float?) {
        
        userDefs[ViewPreferences.key_appModeOnStartup_option] = appModeOnStartup?.option.rawValue
        userDefs[ViewPreferences.key_appModeOnStartup_modeName] = appModeOnStartup?.modeName
        
        userDefs[ViewPreferences.key_layoutOnStartup_option] = layoutOnStartup?.option.rawValue
        userDefs[ViewPreferences.key_layoutOnStartup_layoutName] = layoutOnStartup?.layoutName
        
        userDefs[ViewPreferences.key_snapToWindows] = snapToWindows
        userDefs[ViewPreferences.key_snapToScreen] = snapToScreen
        userDefs[ViewPreferences.key_windowGap] = windowGap
        
        let prefs = ViewPreferences(userDefs.dictionaryRepresentation())
        
        var expectedAppModeOnStartup = appModeOnStartup?.option ?? Defaults.appModeOnStartup.option
        
        if expectedAppModeOnStartup == .specific && appModeOnStartup?.modeName == nil {
            expectedAppModeOnStartup = Defaults.appModeOnStartup.option
        }
        
        XCTAssertEqual(prefs.appModeOnStartup.option,
                       expectedAppModeOnStartup)
        
        XCTAssertEqual(prefs.appModeOnStartup.modeName,
                       appModeOnStartup?.modeName ?? Defaults.appModeOnStartup.modeName)
        
        var expectedLayoutOnStartup = layoutOnStartup?.option ?? Defaults.layoutOnStartup.option
        
        if expectedLayoutOnStartup == .specific && layoutOnStartup?.layoutName == nil {
            expectedLayoutOnStartup = Defaults.layoutOnStartup.option
        }
        
        XCTAssertEqual(prefs.layoutOnStartup.option,
                       expectedLayoutOnStartup)
        
        XCTAssertEqual(prefs.layoutOnStartup.layoutName,
                       layoutOnStartup?.layoutName ?? Defaults.layoutOnStartup.layoutName)
        
        XCTAssertEqual(prefs.snapToWindows, snapToWindows ?? Defaults.snapToWindows)
        XCTAssertEqual(prefs.snapToScreen, snapToScreen ?? Defaults.snapToScreen)
        XCTAssertEqual(prefs.windowGap, windowGap ?? Defaults.windowGap)
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
            
            let deserializedPrefs = ViewPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: .standard)
        }
    }
    
    private func doTestPersist(prefs: ViewPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: ViewPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: ViewPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_appModeOnStartup_option),
                       prefs.appModeOnStartup.option.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_appModeOnStartup_modeName),
                       prefs.appModeOnStartup.modeName)
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_layoutOnStartup_option),
                       prefs.layoutOnStartup.option.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_layoutOnStartup_layoutName),
                       prefs.layoutOnStartup.layoutName)
        
        XCTAssertEqual(userDefs.bool(forKey: ViewPreferences.key_snapToWindows), prefs.snapToWindows)
        XCTAssertEqual(userDefs.bool(forKey: ViewPreferences.key_snapToScreen), prefs.snapToScreen)
        XCTAssertEqual(userDefs.float(forKey: ViewPreferences.key_windowGap), prefs.windowGap)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> ViewPreferences {
        
        let prefs = ViewPreferences([:])
        
        prefs.appModeOnStartup = randomAppModeOnStartup()
        prefs.layoutOnStartup = randomLayoutOnStartup()
        
        prefs.snapToWindows = .random()
        prefs.snapToScreen = .random()
        prefs.windowGap = randomWindowGap()
        
        return prefs
    }
    
    private func randomAppModeOnStartup() -> AppModeOnStartup {
        
        let appMode = AppModeOnStartup()
        
        appMode.option = .randomCase()
        appMode.modeName = randomAppModeName()
        
        return appMode
    }
    
    private func randomLayoutOnStartup() -> LayoutOnStartup {
        
        let layout = LayoutOnStartup()
        
        layout.option = .randomCase()
        layout.layoutName = randomLayoutName()
        
        return layout
    }
    
    private func randomAppModeName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    private func randomLayoutName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    private func randomNillableAppModeOnStartup() -> AppModeOnStartup? {
        randomNillableValue {self.randomAppModeOnStartup()}
    }
    
    private func randomNillableLayoutOnStartup() -> LayoutOnStartup? {
        randomNillableValue {self.randomLayoutOnStartup()}
    }
    
    private func randomWindowGap() -> Float {
        Float.random(in: 0...25)
    }
    
    private func randomNillableWindowGap() -> Float? {
        randomNillableValue {self.randomWindowGap()}
    }
}
