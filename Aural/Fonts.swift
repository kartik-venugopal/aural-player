import Cocoa

/*
    Container for fonts used by the UI
 */
struct Fonts {
    
    struct Constants {
        
        static let gillSans8Font: NSFont = NSFont(name: "Play Regular", size: 8)!
        
        static let gillSans9Font: NSFont = NSFont(name: "Play Regular", size: 9)!
        static let gillSans9SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 9)!
        
        static let gillSans10LightFont: NSFont = NSFont(name: "Play Regular", size: 10)!
        static let gillSans10Font: NSFont = NSFont(name: "Play Regular", size: 10)!
        static let gillSans10SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 10)!
        
        static let gillSans11LightFont: NSFont = NSFont(name: "Play Regular", size: 11)!
        static let gillSans11Font: NSFont = NSFont(name: "Play Regular", size: 11)!
        static let gillSans11SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 11)!
        
        static let gillSans12LightFont: NSFont = NSFont(name: "Play Regular", size: 12)!
        static let gillSans12Font: NSFont = NSFont(name: "Play Regular", size: 12)!
        static let gillSans12SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 12)!
        static let gillSans12BoldFont: NSFont = NSFont(name: "Play Regular", size: 12)!
        
        static let gillSans13LightFont: NSFont = NSFont(name: "Play Regular", size: 13)!
        static let gillSans13Font: NSFont = NSFont(name: "Play Regular", size: 13)!
        static let gillSans13SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 13)!
        
        static let gillSans13_5SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 13.5)!
        
        static let gillSans14Font: NSFont = NSFont(name: "Play Regular", size: 14)!
        static let gillSans14SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 14)!
        
        static let gillSans14_5SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 14.5)!
        
        static let gillSans15Font: NSFont = NSFont(name: "Play Regular", size: 15)!
        static let gillSans15SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 15)!
        
        static let gillSans15_5Font: NSFont = NSFont(name: "Play Regular", size: 15.5)!
        static let gillSans15_5SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 15.5)!
        
        static let gillSans16SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 16)!
        
        static let gillSans16_5SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 16.5)!
        
        static let gillSans17Font: NSFont = NSFont(name: "Play Regular", size: 17)!
        
        static let gillSans18SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 18)!
        
        static let gillSans20SemiBoldFont: NSFont = NSFont(name: "Play Regular", size: 20)!
    }
    
    private static let menuFont_normal: NSFont = Constants.gillSans11Font
    private static let menuFont_larger: NSFont = Constants.gillSans12Font
    private static let menuFont_largest: NSFont = Constants.gillSans13Font
    
    struct Player {
        
        static var menuFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return menuFont_normal
                
            case .larger: return menuFont_larger
                
            case .largest: return menuFont_largest
                
            }
        }
        
        private static let infoBoxTitleFont_normal: NSFont = NSFont(name: "Play Regular", size: 16)!
        private static let infoBoxTitleFont_larger: NSFont = NSFont(name: "Play Regular", size: 18)!
        private static let infoBoxTitleFont_largest: NSFont = NSFont(name: "Play Regular", size: 20)!
        
        static var infoBoxTitleFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return infoBoxTitleFont_normal
                
            case .larger: return infoBoxTitleFont_larger
                
            case .largest: return infoBoxTitleFont_largest
                
            }
        }
        
        private static let gapBoxTitleFont_normal: NSFont = Constants.gillSans14SemiBoldFont
        private static let gapBoxTitleFont_larger: NSFont = Constants.gillSans15SemiBoldFont
        private static let gapBoxTitleFont_largest: NSFont = Constants.gillSans16SemiBoldFont
        
        static var gapBoxTitleFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return gapBoxTitleFont_normal
                
            case .larger: return gapBoxTitleFont_larger
                
            case .largest: return gapBoxTitleFont_largest
                
            }
        }
        
        private static let infoBoxArtistAlbumFont_normal: NSFont = NSFont(name: "Play Regular", size: 14)!
        private static let infoBoxArtistAlbumFont_larger: NSFont = NSFont(name: "Play Regular", size: 16)!
        private static let infoBoxArtistAlbumFont_largest: NSFont = NSFont(name: "Play Regular", size: 18)!
        
        static var infoBoxArtistAlbumFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return infoBoxArtistAlbumFont_normal
                
            case .larger: return infoBoxArtistAlbumFont_larger
                
            case .largest: return infoBoxArtistAlbumFont_largest
                
            }
        }
        
        private static let infoBoxChapterFont_normal: NSFont = Constants.gillSans12Font
        private static let infoBoxChapterFont_larger: NSFont = Constants.gillSans13Font
        private static let infoBoxChapterFont_largest: NSFont = Constants.gillSans14Font
        
        static var infoBoxChapterFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return infoBoxChapterFont_normal
                
            case .larger: return infoBoxChapterFont_larger
                
            case .largest: return infoBoxChapterFont_largest
                
            }
        }
        
        private static let trackTimesFont_normal: NSFont = NSFont(name: "Play Regular", size: 12)!
        private static let trackTimesFont_larger: NSFont = NSFont(name: "Play Regular", size: 13)!
        private static let trackTimesFont_largest: NSFont = NSFont(name: "Play Regular", size: 14)!
        
        static var trackTimesFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return trackTimesFont_normal
                
            case .larger: return trackTimesFont_larger
                
            case .largest: return trackTimesFont_largest
                
            }
        }
        
        private static let feedbackFont_normal: NSFont = Constants.gillSans9SemiBoldFont
        private static let feedbackFont_larger: NSFont = Constants.gillSans10SemiBoldFont
        private static let feedbackFont_largest: NSFont = Constants.gillSans11SemiBoldFont
        
        static var feedbackFont: NSFont {
            
            switch PlayerViewState.textSize {
                
            case .normal: return feedbackFont_normal
                
            case .larger: return feedbackFont_larger
                
            case .largest: return feedbackFont_largest
                
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
        
        private static let indexFont_normal: NSFont = NSFont(name: "Play Regular", size: 13)!
        private static let indexFont_larger: NSFont = NSFont(name: "Play Regular", size: 14)!
        private static let indexFont_largest: NSFont = NSFont(name: "Play Regular", size: 15)!
        
        static var indexFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return indexFont_normal
                
            case .larger: return indexFont_larger
                
            case .largest: return indexFont_largest
                
            }
        }
        
        private static let trackNameFont_normal: NSFont = NSFont(name: "Play Regular", size: 13)!
        private static let trackNameFont_larger: NSFont = NSFont(name: "Play Regular", size: 14)!
        private static let trackNameFont_largest: NSFont = NSFont(name: "Play Regular", size: 15)!
        
        static var trackNameFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return trackNameFont_normal
                
            case .larger: return trackNameFont_larger
                
            case .largest: return trackNameFont_largest
                
            }
        }
        
        private static let groupNameFont_normal: NSFont = NSFont(name: "Play Regular", size: 14)!
        private static let groupNameFont_larger: NSFont = NSFont(name: "Play Regular", size: 15)!
        private static let groupNameFont_largest: NSFont = NSFont(name: "Play Regular", size: 16)!
        
        static var groupNameFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return groupNameFont_normal
                
            case .larger: return groupNameFont_larger
                
            case .largest: return groupNameFont_largest
                
            }
        }
        
        private static let groupDurationFont_normal: NSFont = NSFont(name: "Play Regular", size: 14)!
        private static let groupDurationFont_larger: NSFont = NSFont(name: "Play Regular", size: 15)!
        private static let groupDurationFont_largest: NSFont = NSFont(name: "Play Regular", size: 16)!
        
        static var groupDurationFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return groupDurationFont_normal
                
            case .larger: return groupDurationFont_larger
                
            case .largest: return groupDurationFont_largest
                
            }
        }
        
        private static let summaryFont_normal: NSFont = NSFont(name: "Play Regular", size: 14)!
        private static let summaryFont_larger: NSFont = NSFont(name: "Play Regular", size: 15)!
        private static let summaryFont_largest: NSFont = NSFont(name: "Play Regular", size: 16)!
        
        static var summaryFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return summaryFont_normal
                
            case .larger: return summaryFont_larger
                
            case .largest: return summaryFont_largest
                
            }
        }
        
        private static let chaptersListHeaderFont_normal: NSFont = NSFont(name: "Play Regular", size: 14.5)!
        private static let chaptersListHeaderFont_larger: NSFont = NSFont(name: "Play Regular", size: 15.5)!
        private static let chaptersListHeaderFont_largest: NSFont = NSFont(name: "Play Regular", size: 16.5)!
        
        static var chaptersListHeaderFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return chaptersListHeaderFont_normal
                
            case .larger: return chaptersListHeaderFont_larger
                
            case .largest: return chaptersListHeaderFont_largest
                
            }
        }
        
        static let tabsFont_normal: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 14)!
        static let tabsFont_larger: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 15)!
        static let tabsFont_largest: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 16)!
        
        static var tabsFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return tabsFont_normal
                
            case .larger: return tabsFont_larger
                
            case .largest: return tabsFont_largest
                
            }
        }
        
        static let selectedTabFont_normal: NSFont = NSFont(name: "Alegreya Sans SC Medium", size: 14)!
        static let selectedTabFont_larger: NSFont = NSFont(name: "Alegreya Sans SC Medium", size: 15)!
        static let selectedTabFont_largest: NSFont = NSFont(name: "Alegreya Sans SC Medium", size: 16)!
        
        static var selectedTabFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return selectedTabFont_normal
                
            case .larger: return selectedTabFont_larger
                
            case .largest: return selectedTabFont_largest
                
            }
        }
        
        private static let chapterSearchFont_normal: NSFont = Constants.gillSans12SemiBoldFont
        private static let chapterSearchFont_larger: NSFont = Constants.gillSans13SemiBoldFont
        private static let chapterSearchFont_largest: NSFont = Constants.gillSans14SemiBoldFont
        
        static var chapterSearchFont: NSFont {
            
            switch PlaylistViewState.textSize {
                
            case .normal: return chapterSearchFont_normal
                
            case .larger: return chapterSearchFont_larger
                
            case .largest: return chapterSearchFont_largest
                
            }
        }
        
        private static let chaptersListCaptionFont_normal: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 16)!
        private static let chaptersListCaptionFont_larger: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 18)!
        private static let chaptersListCaptionFont_largest: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 20)!
        
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
        
        private static let tabFont_normal: NSFont = Constants.gillSans12Font
        private static let tabFont_larger: NSFont = Constants.gillSans13Font
        private static let tabFont_largest: NSFont = Constants.gillSans14Font
        
        static var tabFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return tabFont_normal
                
            case .larger: return tabFont_larger
                
            case .largest: return tabFont_largest
                
            }
        }
        
        private static let selectedTabFont_normal: NSFont = Constants.gillSans12SemiBoldFont
        private static let selectedTabFont_larger: NSFont = Constants.gillSans13SemiBoldFont
        private static let selectedTabFont_largest: NSFont = Constants.gillSans14SemiBoldFont
        
        static var selectedTabFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return selectedTabFont_normal
                
            case .larger: return selectedTabFont_larger
                
            case .largest: return selectedTabFont_largest
                
            }
        }
        
        private static let unitCaptionFont_normal: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 16)!
        private static let unitCaptionFont_larger: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 18)!
        private static let unitCaptionFont_largest: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 20)!
        
        static var unitCaptionFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return unitCaptionFont_normal
                
            case .larger: return unitCaptionFont_larger
                
            case .largest: return unitCaptionFont_largest
                
            }
        }
        
        private static let masterUnitFunctionFont_normal: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 13)!
        private static let masterUnitFunctionFont_larger: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 14)!
        private static let masterUnitFunctionFont_largest: NSFont = NSFont(name: "Alegreya Sans SC Regular", size: 15)!
        
        static var masterUnitFunctionFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return masterUnitFunctionFont_normal
                
            case .larger: return masterUnitFunctionFont_larger
                
            case .largest: return masterUnitFunctionFont_largest
                
            }
        }
        
        private static let unitFunctionFont_normal: NSFont = NSFont(name: "Play Regular", size: 11.5)!
        private static let unitFunctionFont_larger: NSFont = NSFont(name: "Play Regular", size: 12.5)!
        private static let unitFunctionFont_largest: NSFont = NSFont(name: "Play Regular", size: 13.5)!
        
        static var unitFunctionFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return unitFunctionFont_normal
                
            case .larger: return unitFunctionFont_larger
                
            case .largest: return unitFunctionFont_largest
                
            }
        }
        
        private static let unitFunctionBoldFont_normal: NSFont = Constants.gillSans11SemiBoldFont
        private static let unitFunctionBoldFont_larger: NSFont = Constants.gillSans12SemiBoldFont
        private static let unitFunctionBoldFont_largest: NSFont = Constants.gillSans13SemiBoldFont
        
        static var unitFunctionBoldFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return unitFunctionBoldFont_normal
                
            case .larger: return unitFunctionBoldFont_larger
                
            case .largest: return unitFunctionBoldFont_largest
                
            }
        }
        
        private static let filterChartFont_normal: NSFont = Constants.gillSans9SemiBoldFont
        private static let filterChartFont_larger: NSFont = Constants.gillSans10SemiBoldFont
        private static let filterChartFont_largest: NSFont = Constants.gillSans11SemiBoldFont
        
        static var filterChartFont: NSFont {
            
            switch EffectsViewState.textSize {
                
            case .normal: return filterChartFont_normal
                
            case .larger: return filterChartFont_larger
                
            case .largest: return filterChartFont_largest
                
            }
        }
    }
    
    private static let stringInputPopoverFont_normal: NSFont = Constants.gillSans12Font
    private static let stringInputPopoverFont_larger: NSFont = Constants.gillSans13Font
    private static let stringInputPopoverFont_largest: NSFont = Constants.gillSans14Font
    
    static func stringInputPopoverFont(_ size: TextSize) -> NSFont {
        
        switch size {
            
        case .normal: return stringInputPopoverFont_normal
            
        case .larger: return stringInputPopoverFont_larger
            
        case .largest: return stringInputPopoverFont_largest
            
        }
    }
    
    private static let stringInputPopoverErrorFont_normal: NSFont = Constants.gillSans11Font
    private static let stringInputPopoverErrorFont_larger: NSFont = Constants.gillSans12Font
    private static let stringInputPopoverErrorFont_largest: NSFont = Constants.gillSans13Font
    
    static func stringInputPopoverErrorFont(_ size: TextSize) -> NSFont {
        
        switch size {
            
        case .normal: return stringInputPopoverErrorFont_normal
            
        case .larger: return stringInputPopoverErrorFont_larger
            
        case .largest: return stringInputPopoverErrorFont_largest
            
        }
    }
    
    static let helpInfoTextFont: NSFont = Constants.gillSans12Font
    
    static let editorTableHeaderTextFont: NSFont = Constants.gillSans13SemiBoldFont
    static let editorTableTextFont: NSFont = Constants.gillSans12LightFont
    static let editorTableSelectedTextFont: NSFont = Constants.gillSans12Font
    
    // Font used by the playlist tab view buttons
    static let tabViewButtonFont: NSFont = Constants.gillSans12Font
    static let tabViewButtonBoldFont: NSFont = Constants.gillSans12SemiBoldFont
    
    // FX tab view buttons
    static let tabViewButtonFont_small: NSFont = Constants.gillSans11Font
    static let tabViewButtonBoldFont_small: NSFont = Constants.gillSans11SemiBoldFont
    
    static let progressArcFont: NSFont = Constants.gillSans14Font
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = Constants.gillSans12Font
    
    // Font used by modal dialog control buttons
    static let modalDialogControlButtonFont: NSFont = Constants.gillSans11Font
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = Constants.gillSans12BoldFont
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = Constants.gillSans11Font
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = Constants.gillSans10Font
}
