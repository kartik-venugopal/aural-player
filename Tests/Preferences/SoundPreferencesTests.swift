//
//  SoundPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class SoundPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Sound
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   outputDeviceOnStartup: nil,
                   volumeDelta: nil,
                   volumeOnStartupOption: nil,
                   startupVolumeValue: nil,
                   panDelta: nil,
                   eqDelta: nil,
                   pitchDelta: nil,
                   timeDelta: nil,
                   effectsSettingsOnStartupOption: nil,
                   masterPresetOnStartup_name: nil,
                   rememberEffectsSettingsOption: nil)
    }
    
    func testInit_someValues() {

        for _ in 1...100 {

            doTestInit(userDefs: UserDefaults(),
                       outputDeviceOnStartup: randomNillableOutputDevice(),
                       volumeDelta: randomNillableVolumeDelta(),
                       volumeOnStartupOption: randomNillableVolumeStartupOptions(),
                       startupVolumeValue: randomNillableStartupVolumeValue(),
                       panDelta: randomNillablePanDelta(),
                       eqDelta: randomNillableEQDelta(),
                       pitchDelta: randomNillablePitchDelta(),
                       timeDelta: randomNillableTimeDelta(),
                       effectsSettingsOnStartupOption: randomNillableEffectsSettingsStartupOptions(),
                       masterPresetOnStartup_name: randomNillableMasterPresetName(),
                       rememberEffectsSettingsOption: randomNillableRememberSettingsForTrackOptions())
        }
    }
    
    func testInit_preferredOutputDevice() {
        doTestInit_withPreferredOutputDevice(name: randomDeviceName(), uid: randomDeviceUID())
    }
    
    func testInit_preferredOutputDevice_noDeviceNameSpecified() {
        doTestInit_withPreferredOutputDevice(name: nil, uid: randomDeviceUID())
    }
    
    func testInit_preferredOutputDevice_noDeviceUIDSpecified() {
        doTestInit_withPreferredOutputDevice(name: randomDeviceName(), uid: nil)
    }
    
    func testInit_preferredOutputDevice_noDeviceNameOrUIDSpecified() {
        doTestInit_withPreferredOutputDevice(name: nil, uid: nil)
    }
    
    private func doTestInit_withPreferredOutputDevice(name: String?, uid: String?) {
        
        let device = OutputDeviceOnStartup()
        device.option = .specific
        device.preferredDeviceName = name
        device.preferredDeviceUID = uid
        
        doTestInit(userDefs: UserDefaults(),
                   outputDeviceOnStartup: device,
                   volumeDelta: randomVolumeDelta(),
                   volumeOnStartupOption: .randomCase(),
                   startupVolumeValue: randomStartupVolumeValue(),
                   panDelta: randomPanDelta(),
                   eqDelta: randomEQDelta(),
                   pitchDelta: randomPitchDelta(),
                   timeDelta: randomTimeDelta(),
                   effectsSettingsOnStartupOption: .applyMasterPreset,
                   masterPresetOnStartup_name: randomMasterPresetName(),
                   rememberEffectsSettingsOption: .randomCase())
    }
    
    func testInit_applyMasterPreset() {

        doTestInit(userDefs: UserDefaults(),
                   outputDeviceOnStartup: randomOutputDevice(),
                   volumeDelta: randomVolumeDelta(),
                   volumeOnStartupOption: .randomCase(),
                   startupVolumeValue: randomStartupVolumeValue(),
                   panDelta: randomPanDelta(),
                   eqDelta: randomEQDelta(),
                   pitchDelta: randomPitchDelta(),
                   timeDelta: randomTimeDelta(),
                   effectsSettingsOnStartupOption: .applyMasterPreset,
                   masterPresetOnStartup_name: randomMasterPresetName(),
                   rememberEffectsSettingsOption: .randomCase())
    }
    
    func testInit_applyMasterPreset_noMasterPresetSpecified() {

        doTestInit(userDefs: UserDefaults(),
                   outputDeviceOnStartup: randomOutputDevice(),
                   volumeDelta: randomVolumeDelta(),
                   volumeOnStartupOption: .randomCase(),
                   startupVolumeValue: randomStartupVolumeValue(),
                   panDelta: randomPanDelta(),
                   eqDelta: randomEQDelta(),
                   pitchDelta: randomPitchDelta(),
                   timeDelta: randomTimeDelta(),
                   effectsSettingsOnStartupOption: .applyMasterPreset,
                   masterPresetOnStartup_name: nil,
                   rememberEffectsSettingsOption: .randomCase())
    }
    
    func testInit() {

        for _ in 1...100 {

            doTestInit(userDefs: UserDefaults(),
                       outputDeviceOnStartup: randomOutputDevice(),
                       volumeDelta: randomVolumeDelta(),
                       volumeOnStartupOption: .randomCase(),
                       startupVolumeValue: randomStartupVolumeValue(),
                       panDelta: randomPanDelta(),
                       eqDelta: randomEQDelta(),
                       pitchDelta: randomPitchDelta(),
                       timeDelta: randomTimeDelta(),
                       effectsSettingsOnStartupOption: .randomCase(),
                       masterPresetOnStartup_name: randomMasterPresetName(),
                       rememberEffectsSettingsOption: .randomCase())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            outputDeviceOnStartup: OutputDeviceOnStartup?,
                            volumeDelta: Float?,
                            volumeOnStartupOption: VolumeStartupOptions?,
                            startupVolumeValue: Float?,
                            panDelta: Float?,
                            eqDelta: Float?,
                            pitchDelta: Int?,
                            timeDelta: Float?,
                            effectsSettingsOnStartupOption: EffectsSettingsStartupOptions?,
                            masterPresetOnStartup_name: String?,
                            rememberEffectsSettingsOption: RememberSettingsForTrackOptions?) {
        
        userDefs[SoundPreferences.key_outputDeviceOnStartup_option] = outputDeviceOnStartup?.option.rawValue
        userDefs[SoundPreferences.key_outputDeviceOnStartup_preferredDeviceName] = outputDeviceOnStartup?.preferredDeviceName
        userDefs[SoundPreferences.key_outputDeviceOnStartup_preferredDeviceUID] = outputDeviceOnStartup?.preferredDeviceUID
        
        userDefs[SoundPreferences.key_volumeDelta] = volumeDelta
        userDefs[SoundPreferences.key_volumeOnStartup_option] = volumeOnStartupOption?.rawValue
        userDefs[SoundPreferences.key_volumeOnStartup_value] = startupVolumeValue
        
        userDefs[SoundPreferences.key_panDelta] = panDelta
        
        userDefs[SoundPreferences.key_eqDelta] = eqDelta
        userDefs[SoundPreferences.key_pitchDelta] = pitchDelta
        userDefs[SoundPreferences.key_timeDelta] = timeDelta
        
        userDefs[SoundPreferences.key_effectsSettingsOnStartup_option] = effectsSettingsOnStartupOption?.rawValue
        userDefs[SoundPreferences.key_effectsSettingsOnStartup_masterPreset] = masterPresetOnStartup_name
        userDefs[SoundPreferences.key_rememberEffectsSettingsOption] = rememberEffectsSettingsOption?.rawValue
        
        let prefs = SoundPreferences(userDefs.dictionaryRepresentation())
        
        var expectedOutputDeviceOnStartupOption = outputDeviceOnStartup?.option ?? Defaults.outputDeviceOnStartup.option
        
        if outputDeviceOnStartup?.option == .specific &&
            (outputDeviceOnStartup?.preferredDeviceName == nil || outputDeviceOnStartup?.preferredDeviceUID == nil) {
            
            expectedOutputDeviceOnStartupOption = Defaults.outputDeviceOnStartup.option
        }
        
        XCTAssertEqual(prefs.outputDeviceOnStartup.option, expectedOutputDeviceOnStartupOption)
        
        XCTAssertEqual(prefs.outputDeviceOnStartup.preferredDeviceName,
                       outputDeviceOnStartup?.preferredDeviceName ?? Defaults.outputDeviceOnStartup.preferredDeviceName)
        
        XCTAssertEqual(prefs.outputDeviceOnStartup.preferredDeviceUID,
                       outputDeviceOnStartup?.preferredDeviceUID ?? Defaults.outputDeviceOnStartup.preferredDeviceUID)
        
        XCTAssertEqual(prefs.volumeDelta, volumeDelta ?? Defaults.volumeDelta)
        XCTAssertEqual(prefs.volumeOnStartupOption, volumeOnStartupOption ?? Defaults.volumeOnStartupOption)
        XCTAssertEqual(prefs.startupVolumeValue, startupVolumeValue ?? Defaults.startupVolumeValue)
        
        XCTAssertEqual(prefs.panDelta, panDelta ?? Defaults.panDelta)
        
        XCTAssertEqual(prefs.eqDelta, eqDelta ?? Defaults.eqDelta)
        XCTAssertEqual(prefs.pitchDelta, pitchDelta ?? Defaults.pitchDelta)
        XCTAssertEqual(prefs.timeDelta, timeDelta ?? Defaults.timeDelta)
        
        var expectedEffectsSettingsOnStartupOption = effectsSettingsOnStartupOption ?? Defaults.effectsSettingsOnStartupOption
        
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            expectedEffectsSettingsOnStartupOption = Defaults.effectsSettingsOnStartupOption
        }
        
        XCTAssertEqual(prefs.effectsSettingsOnStartupOption, expectedEffectsSettingsOnStartupOption)
        
        XCTAssertEqual(prefs.masterPresetOnStartup_name,
                       masterPresetOnStartup_name ?? Defaults.masterPresetOnStartup_name)
        
        XCTAssertEqual(prefs.rememberEffectsSettingsOption,
                       rememberEffectsSettingsOption ?? Defaults.rememberEffectsSettingsOption)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {

        for _ in 1...100 {
            doTestPersist(prefs: randomSoundPreferences())
        }
    }

    func testPersist_serializeAndDeserialize() {

        for _ in 1...100 {

            let defaults = UserDefaults()
            let serializedPrefs = randomSoundPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)

            let deserializedPrefs = SoundPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: SoundPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: SoundPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
