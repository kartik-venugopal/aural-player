/*
    Encapsulates all application state, with values that are marshaled into a format directly usable by the UI, based on user preferences.
 */

import Foundation

class UIAppState {
    
    var hidePlaylist: Bool
    var hideEffects: Bool
    
    var windowLocationOnStartup: WindowLocationOnStartup
    var windowLocationXY: NSPoint?
    var playlistLocation: PlaylistLocations
    
    var repeatMode: RepeatMode
    var shuffleMode: ShuffleMode
    
    var volume: Float
    var muted: Bool
    var balance: Float
    
    var eqBypass: Bool
    var eqGlobalGain: Float
    var eqBands: [Int: Float] = [Int: Float]()
    
    var pitchBypass: Bool
    var pitch: Float
    var pitchOverlap: Float
    
    var formattedPitch: String
    var formattedPitchOverlap: String
    
    var timeBypass: Bool
    var timeShiftPitch: Bool
    var timeStretchRate: Float
    var timeOverlap: Float
    
    var formattedTimeStretchRate: String
    var formattedTimeOverlap: String
    
    var seekTimerInterval: Int
    
    var reverbBypass: Bool
    var reverbSpace: String
    var reverbAmount: Float
    
    var formattedReverbAmount: String
    
    var delayBypass: Bool
    var delayAmount: Float
    var delayTime: Double
    var delayFeedback: Float
    var delayLowPassCutoff: Float
    
    var formattedDelayAmount: String
    var formattedDelayTime: String
    var formattedDelayFeedback: String
    var formattedDelayLowPassCutoff: String
    
    var filterBypass: Bool
    var filterBassMin: Double
    var filterBassMax: Double
    var filterMidMin: Double
    var filterMidMax: Double
    var filterTrebleMin: Double
    var filterTrebleMax: Double
    
    var formattedFilterBassRange: String
    var formattedFilterMidRange: String
    var formattedFilterTrebleRange: String
    
    init(_ appState: AppState, _ preferences: Preferences) {
        
        if (preferences.viewPreferences.viewOnStartup.option == .rememberFromLastAppLaunch) {
            
            self.hidePlaylist = !appState.uiState.showPlaylist
            self.hideEffects = !appState.uiState.showEffects
            
        } else {
            
            let viewType = preferences.viewPreferences.viewOnStartup.viewType
            self.hidePlaylist = viewType == .effectsOnly || viewType == .compact
            self.hideEffects = viewType == .playlistOnly || viewType == .compact
        }
        
        if (preferences.viewPreferences.playlistLocationOnStartup.option == .rememberFromLastAppLaunch) {
            
            self.playlistLocation = appState.uiState.playlistLocation
            
        } else {
            
            self.playlistLocation = preferences.viewPreferences.playlistLocationOnStartup.playlistLocation
        }
        
        self.windowLocationOnStartup = preferences.viewPreferences.windowLocationOnStartup
        
        if (preferences.viewPreferences.windowLocationOnStartup.option == .rememberFromLastAppLaunch) {
            
            self.windowLocationXY = NSPoint(x: CGFloat(appState.uiState.windowLocationX), y: CGFloat(appState.uiState.windowLocationY))
        }
        
        self.repeatMode = appState.playbackSequenceState.repeatMode
        self.shuffleMode = appState.playbackSequenceState.shuffleMode
        
        let audioGraphState = appState.audioGraphState
        
        if (preferences.soundPreferences.volumeOnStartup == .rememberFromLastAppLaunch) {
            self.volume = round(audioGraphState.volume * AppConstants.volumeConversion_audioGraphToUI)
            self.muted = audioGraphState.muted
        } else {
            self.volume = round(preferences.soundPreferences.startupVolumeValue * AppConstants.volumeConversion_audioGraphToUI)
            self.muted = false
        }
        
        self.balance = round(audioGraphState.balance * AppConstants.panConversion_audioGraphToUI)
        
        self.eqBypass = audioGraphState.eqBypass
        self.eqGlobalGain = audioGraphState.eqGlobalGain
        for (freq,gain) in audioGraphState.eqBands {
            self.eqBands[freq] = gain
        }
        
        self.pitchBypass = audioGraphState.pitchBypass
        self.pitch = audioGraphState.pitch * AppConstants.pitchConversion_audioGraphToUI
        self.pitchOverlap = audioGraphState.pitchOverlap
        
        self.formattedPitch = ValueFormatter.formatPitch(self.pitch)
        self.formattedPitchOverlap = ValueFormatter.formatOverlap(audioGraphState.pitchOverlap)
        
        self.timeBypass = audioGraphState.timeBypass
        self.timeStretchRate = audioGraphState.timeStretchRate
        self.timeShiftPitch = audioGraphState.timeShiftPitch
        self.timeOverlap = audioGraphState.timeOverlap
        
        self.formattedTimeStretchRate = ValueFormatter.formatTimeStretchRate(audioGraphState.timeStretchRate)
        self.formattedTimeOverlap = ValueFormatter.formatOverlap(audioGraphState.timeOverlap)
        
        self.seekTimerInterval = audioGraphState.timeBypass ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * audioGraphState.timeStretchRate))
        
        self.reverbBypass = audioGraphState.reverbBypass
        self.reverbSpace = audioGraphState.reverbSpace.description
        self.reverbAmount = audioGraphState.reverbAmount
        
        self.formattedReverbAmount = ValueFormatter.formatReverbAmount(audioGraphState.reverbAmount)
        
        self.delayBypass = audioGraphState.delayBypass
        self.delayTime = audioGraphState.delayTime
        self.delayAmount = audioGraphState.delayAmount
        self.delayFeedback = audioGraphState.delayFeedback
        self.delayLowPassCutoff = audioGraphState.delayLowPassCutoff
        
        self.formattedDelayTime = ValueFormatter.formatDelayTime(audioGraphState.delayTime)
        self.formattedDelayAmount = ValueFormatter.formatDelayAmount(audioGraphState.delayAmount)
        self.formattedDelayFeedback = ValueFormatter.formatDelayFeedback(audioGraphState.delayFeedback)
        self.formattedDelayLowPassCutoff = ValueFormatter.formatDelayLowPassCutoff(audioGraphState.delayLowPassCutoff)
         
        self.filterBypass = audioGraphState.filterBypass
        self.filterBassMin = Double(audioGraphState.filterBassMin)
        self.filterBassMax = Double(audioGraphState.filterBassMax)
        self.filterMidMin = Double(audioGraphState.filterMidMin)
        self.filterMidMax = Double(audioGraphState.filterMidMax)
        self.filterTrebleMin = Double(audioGraphState.filterTrebleMin)
        self.filterTrebleMax = Double(audioGraphState.filterTrebleMax)
        
        self.formattedFilterBassRange = ValueFormatter.formatFilterFrequencyRange(audioGraphState.filterBassMin, audioGraphState.filterBassMax)
        self.formattedFilterMidRange = ValueFormatter.formatFilterFrequencyRange(audioGraphState.filterMidMin, audioGraphState.filterMidMax)
        self.formattedFilterTrebleRange = ValueFormatter.formatFilterFrequencyRange(audioGraphState.filterTrebleMin, audioGraphState.filterTrebleMax)
    }
}
