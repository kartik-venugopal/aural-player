//
//  ViewPreferencesTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
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
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
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
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
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
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            doTestPersist(prefs: randomViewPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomViewPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = ViewPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: ViewPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: ViewPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
