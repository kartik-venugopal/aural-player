import Cocoa

/*
    Container for fonts used by the UI
 */
struct Fonts {
    
    struct Constants {
        
        static let mainFont_8: NSFont = NSFont(name: "Play Regular", size: 8)!
        
        static let mainFont_9: NSFont = NSFont(name: "Play Regular", size: 9)!
        
        static let mainFont_10: NSFont = NSFont(name: "Play Regular", size: 10)!
        
        static let mainFont_11: NSFont = NSFont(name: "Play Regular", size: 11)!
        static let mainFont_11_5: NSFont = NSFont(name: "Play Regular", size: 11.5)!
        
        static let mainFont_12: NSFont = NSFont(name: "Play Regular", size: 12)!
        static let mainFont_12_5: NSFont = NSFont(name: "Play Regular", size: 12.5)!
        
        static let mainFont_13: NSFont = NSFont(name: "Play Regular", size: 13)!
        static let mainFont_13_5: NSFont = NSFont(name: "Play Regular", size: 13.5)!
        
        static let mainFont_14: NSFont = NSFont(name: "Play Regular", size: 14)!
        static let mainFont_14_5: NSFont = NSFont(name: "Play Regular", size: 14.5)!
        
        static let mainFont_15: NSFont = NSFont(name: "Play Regular", size: 15)!
        static let mainFont_15_5: NSFont = NSFont(name: "Play Regular", size: 15.5)!
        
        static let mainFont_16: NSFont = NSFont(name: "Play Regular", size: 16)!
        static let mainFont_16_5: NSFont = NSFont(name: "Play Regular", size: 16.5)!
        
        static let mainFont_17: NSFont = NSFont(name: "Play Regular", size: 17)!
        
        static let mainFont_18: NSFont = NSFont(name: "Play Regular", size: 18)!
        
        static let mainFont_20: NSFont = NSFont(name: "Play Regular", size: 20)!
        
        static let captionFont_13: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 13)!
        static let captionFont_14: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 14)!
        static let captionFont_15: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 15)!
        static let captionFont_16: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 16)!
        
        static let captionMediumFont_14: NSFont = NSFont(name: "Alegreya Sans SC Medium", size: 14)!
        static let captionMediumFont_15: NSFont = NSFont(name: "Alegreya Sans SC Medium", size: 15)!
        static let captionMediumFont_16: NSFont = NSFont(name: "Alegreya Sans SC Medium", size: 16)!
        
        static let captionFont_18: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 18)!
        static let captionFont_20: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 20)!
    }
    
    private static let menuFont_normal: NSFont = Constants.mainFont_11
    private static let menuFont_larger: NSFont = Constants.mainFont_12
    private static let menuFont_largest: NSFont = Constants.mainFont_13
    
    struct Player {
        
        static var menuFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return menuFont_normal
                
            case .larger: return menuFont_larger
                
            case .largest: return menuFont_largest
                
            }
        }
        
        private static let infoBoxTitleFont_normal: NSFont = Constants.mainFont_16
        private static let infoBoxTitleFont_larger: NSFont = Constants.mainFont_18
        private static let infoBoxTitleFont_largest: NSFont = Constants.mainFont_20
        
        static var infoBoxTitleFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return infoBoxTitleFont_normal
                
            case .larger: return infoBoxTitleFont_larger
                
            case .largest: return infoBoxTitleFont_largest
                
            }
        }
        
        private static let gapBoxTitleFont_normal: NSFont = Constants.mainFont_14
        private static let gapBoxTitleFont_larger: NSFont = Constants.mainFont_15
        private static let gapBoxTitleFont_largest: NSFont = Constants.mainFont_16
        
        static var gapBoxTitleFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return gapBoxTitleFont_normal
                
            case .larger: return gapBoxTitleFont_larger
                
            case .largest: return gapBoxTitleFont_largest
                
            }
        }
        
        private static let infoBoxArtistAlbumFont_normal: NSFont = Constants.mainFont_14
        private static let infoBoxArtistAlbumFont_larger: NSFont = Constants.mainFont_16
        private static let infoBoxArtistAlbumFont_largest: NSFont = Constants.mainFont_18
        
        static var infoBoxArtistAlbumFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return infoBoxArtistAlbumFont_normal
                
            case .larger: return infoBoxArtistAlbumFont_larger
                
            case .largest: return infoBoxArtistAlbumFont_largest
                
            }
        }
        
        private static let infoBoxChapterFont_normal: NSFont = Constants.mainFont_12
        private static let infoBoxChapterFont_larger: NSFont = Constants.mainFont_13
        private static let infoBoxChapterFont_largest: NSFont = Constants.mainFont_14
        
        static var infoBoxChapterFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return infoBoxChapterFont_normal
                
            case .larger: return infoBoxChapterFont_larger
                
            case .largest: return infoBoxChapterFont_largest
                
            }
        }
        
        private static let trackTimesFont_normal: NSFont = Constants.mainFont_12
        private static let trackTimesFont_larger: NSFont = Constants.mainFont_13
        private static let trackTimesFont_largest: NSFont = Constants.mainFont_14
        
        static var trackTimesFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return trackTimesFont_normal
                
            case .larger: return trackTimesFont_larger
                
            case .largest: return trackTimesFont_largest
                
            }
        }
        
        private static let feedbackFont_normal: NSFont = Constants.mainFont_9
        private static let feedbackFont_larger: NSFont = Constants.mainFont_10
        private static let feedbackFont_largest: NSFont = Constants.mainFont_11
        
        static var feedbackFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return feedbackFont_normal
                
            case .larger: return feedbackFont_larger
                
            case .largest: return feedbackFont_largest
                
            }
        }
        
        private static let textButtonFont_normal: NSFont = Constants.mainFont_12
        private static let textButtonFont_larger: NSFont = Constants.mainFont_13
        private static let textButtonFont_largest: NSFont = Constants.mainFont_14
        
        static var textButtonFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return textButtonFont_normal
                
            case .larger: return textButtonFont_larger
                
            case .largest: return textButtonFont_largest
                
            }
        }
    }
    
    struct Playlist {
        
        static var menuFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return menuFont_normal
                
            case .larger: return menuFont_larger
                
            case .largest: return menuFont_largest
                
            }
        }
        
        private static let indexFont_normal: NSFont = Constants.mainFont_13
        private static let indexFont_larger: NSFont = Constants.mainFont_14
        private static let indexFont_largest: NSFont = Constants.mainFont_15
        
        static var indexFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return indexFont_normal
                
            case .larger: return indexFont_larger
                
            case .largest: return indexFont_largest
                
            }
        }
        
        private static let trackNameFont_normal: NSFont = Constants.mainFont_13
        private static let trackNameFont_larger: NSFont = Constants.mainFont_14
        private static let trackNameFont_largest: NSFont = Constants.mainFont_15
        
        static var trackNameFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return trackNameFont_normal
                
            case .larger: return trackNameFont_larger
                
            case .largest: return trackNameFont_largest
                
            }
        }
        
        private static let groupNameFont_normal: NSFont = Constants.mainFont_14
        private static let groupNameFont_larger: NSFont = Constants.mainFont_15
        private static let groupNameFont_largest: NSFont = Constants.mainFont_16
        
        static var groupNameFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return groupNameFont_normal
                
            case .larger: return groupNameFont_larger
                
            case .largest: return groupNameFont_largest
                
            }
        }
        
        private static let groupDurationFont_normal: NSFont = Constants.mainFont_14
        private static let groupDurationFont_larger: NSFont = Constants.mainFont_15
        private static let groupDurationFont_largest: NSFont = Constants.mainFont_16
        
        static var groupDurationFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return groupDurationFont_normal
                
            case .larger: return groupDurationFont_larger
                
            case .largest: return groupDurationFont_largest
                
            }
        }
        
        private static let summaryFont_normal: NSFont = Constants.mainFont_14
        private static let summaryFont_larger: NSFont = Constants.mainFont_15
        private static let summaryFont_largest: NSFont = Constants.mainFont_16
        
        static var summaryFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return summaryFont_normal
                
            case .larger: return summaryFont_larger
                
            case .largest: return summaryFont_largest
                
            }
        }
        
        private static let chaptersListHeaderFont_normal: NSFont = Constants.mainFont_14_5
        private static let chaptersListHeaderFont_larger: NSFont = Constants.mainFont_15_5
        private static let chaptersListHeaderFont_largest: NSFont = Constants.mainFont_16_5
        
        static var chaptersListHeaderFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return chaptersListHeaderFont_normal
                
            case .larger: return chaptersListHeaderFont_larger
                
            case .largest: return chaptersListHeaderFont_largest
                
            }
        }
        
        static let tabsFont_normal: NSFont = Constants.captionFont_14
        static let tabsFont_larger: NSFont = Constants.captionFont_15
        static let tabsFont_largest: NSFont = Constants.captionFont_16
        
        static var tabsFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return tabsFont_normal
                
            case .larger: return tabsFont_larger
                
            case .largest: return tabsFont_largest
                
            }
        }
        
        static let selectedTabFont_normal: NSFont = Constants.captionMediumFont_14
        static let selectedTabFont_larger: NSFont = Constants.captionMediumFont_15
        static let selectedTabFont_largest: NSFont = Constants.captionMediumFont_16
        
        static var selectedTabFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return selectedTabFont_normal
                
            case .larger: return selectedTabFont_larger
                
            case .largest: return selectedTabFont_largest
                
            }
        }
        
        private static let chapterSearchFont_normal: NSFont = Constants.mainFont_12
        private static let chapterSearchFont_larger: NSFont = Constants.mainFont_13
        private static let chapterSearchFont_largest: NSFont = Constants.mainFont_14
        
        static var chapterSearchFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return chapterSearchFont_normal
                
            case .larger: return chapterSearchFont_larger
                
            case .largest: return chapterSearchFont_largest
                
            }
        }
        
        private static let chaptersListCaptionFont_normal: NSFont = Constants.captionFont_16
        private static let chaptersListCaptionFont_larger: NSFont = Constants.captionFont_18
        private static let chaptersListCaptionFont_largest: NSFont = Constants.captionFont_20
        
        static var chaptersListCaptionFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return chaptersListCaptionFont_normal
                
            case .larger: return chaptersListCaptionFont_larger
                
            case .largest: return chaptersListCaptionFont_largest
                
            }
        }
    }
    
    struct Effects {
        
        static var menuFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return menuFont_normal
                
            case .larger: return menuFont_larger
                
            case .largest: return menuFont_largest
                
            }
        }
        
        private static let tabFont_normal: NSFont = Constants.mainFont_12
        private static let tabFont_larger: NSFont = Constants.mainFont_13
        private static let tabFont_largest: NSFont = Constants.mainFont_14
        
        static var tabFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return tabFont_normal
                
            case .larger: return tabFont_larger
                
            case .largest: return tabFont_largest
                
            }
        }
        
        private static let selectedTabFont_normal: NSFont = Constants.mainFont_12
        private static let selectedTabFont_larger: NSFont = Constants.mainFont_13
        private static let selectedTabFont_largest: NSFont = Constants.mainFont_14
        
        static var selectedTabFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return selectedTabFont_normal
                
            case .larger: return selectedTabFont_larger
                
            case .largest: return selectedTabFont_largest
                
            }
        }
        
        private static let unitCaptionFont_normal: NSFont = Constants.captionFont_16
        private static let unitCaptionFont_larger: NSFont = Constants.captionFont_18
        private static let unitCaptionFont_largest: NSFont = Constants.captionFont_20
        
        static var unitCaptionFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return unitCaptionFont_normal
                
            case .larger: return unitCaptionFont_larger
                
            case .largest: return unitCaptionFont_largest
                
            }
        }
        
        private static let masterUnitFunctionFont_normal: NSFont = Constants.captionFont_13
        private static let masterUnitFunctionFont_larger: NSFont = Constants.captionFont_14
        private static let masterUnitFunctionFont_largest: NSFont = Constants.captionFont_15
        
        static var masterUnitFunctionFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return masterUnitFunctionFont_normal
                
            case .larger: return masterUnitFunctionFont_larger
                
            case .largest: return masterUnitFunctionFont_largest
                
            }
        }
        
        private static let unitFunctionFont_normal: NSFont = Constants.mainFont_11_5
        private static let unitFunctionFont_larger: NSFont = Constants.mainFont_12_5
        private static let unitFunctionFont_largest: NSFont = Constants.mainFont_13_5
        
        static var unitFunctionFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return unitFunctionFont_normal
                
            case .larger: return unitFunctionFont_larger
                
            case .largest: return unitFunctionFont_largest
                
            }
        }
        
        private static let unitFunctionBoldFont_normal: NSFont = Constants.mainFont_11
        private static let unitFunctionBoldFont_larger: NSFont = Constants.mainFont_12
        private static let unitFunctionBoldFont_largest: NSFont = Constants.mainFont_13
        
        static var unitFunctionBoldFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return unitFunctionBoldFont_normal
                
            case .larger: return unitFunctionBoldFont_larger
                
            case .largest: return unitFunctionBoldFont_largest
                
            }
        }
        
        private static let filterChartFont_normal: NSFont = Constants.mainFont_9
        private static let filterChartFont_larger: NSFont = Constants.mainFont_10
        private static let filterChartFont_largest: NSFont = Constants.mainFont_11
        
        static var filterChartFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return filterChartFont_normal
                
            case .larger: return filterChartFont_larger
                
            case .largest: return filterChartFont_largest
                
            }
        }
    }
    
    private static let stringInputPopoverFont_normal: NSFont = Constants.mainFont_12
    private static let stringInputPopoverFont_larger: NSFont = Constants.mainFont_13
    private static let stringInputPopoverFont_largest: NSFont = Constants.mainFont_14
    
    static func stringInputPopoverFont(_ size: TextSize) -> NSFont {
        
        switch size {
            
        case .normal: return stringInputPopoverFont_normal
            
        case .larger: return stringInputPopoverFont_larger
            
        case .largest: return stringInputPopoverFont_largest
            
        }
    }
    
    private static let stringInputPopoverErrorFont_normal: NSFont = Constants.mainFont_11
    private static let stringInputPopoverErrorFont_larger: NSFont = Constants.mainFont_12
    private static let stringInputPopoverErrorFont_largest: NSFont = Constants.mainFont_13
    
    static func stringInputPopoverErrorFont(_ size: TextSize) -> NSFont {
        
        switch size {
            
        case .normal: return stringInputPopoverErrorFont_normal
            
        case .larger: return stringInputPopoverErrorFont_larger
            
        case .largest: return stringInputPopoverErrorFont_largest
            
        }
    }
    
    static let helpInfoTextFont: NSFont = Constants.mainFont_12
    
    static let editorTableHeaderTextFont: NSFont = Constants.mainFont_13
    static let editorTableTextFont: NSFont = Constants.mainFont_12
    static let editorTableSelectedTextFont: NSFont = Constants.mainFont_12
    
    // Font used by the playlist tab view buttons
    static let tabViewButtonFont: NSFont = Constants.mainFont_12
    static let tabViewButtonBoldFont: NSFont = Constants.mainFont_12
    
    // FX tab view buttons
    static let tabViewButtonFont_smallFont: NSFont = Constants.mainFont_11
    static let tabViewButtonBoldFont_smallFont: NSFont = Constants.mainFont_11
    
    static let progressArcFont: NSFont = Constants.mainFont_14
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = Constants.mainFont_12
    
    // Font used by modal dialog control buttons
    static let modalDialogControlButtonFont: NSFont = Constants.mainFont_11
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = Constants.mainFont_12
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = Constants.mainFont_11
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = Constants.mainFont_10
}
