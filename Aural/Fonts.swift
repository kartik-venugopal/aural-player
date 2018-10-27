/*
    Container for fonts used by the UI
 */

import Cocoa

struct Fonts {
    
    static let gillSans11Font: NSFont = NSFont(name: "Gill Sans", size: 11)!
    static let gillSans10Font: NSFont = NSFont(name: "Gill Sans", size: 10)!
    static let gillSans10LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 10)!
    static let gillSans11LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 11)!
    
    static let gillSans12LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 12)!
    static let gillSans12Font: NSFont = NSFont(name: "Gill Sans", size: 12)!
    static let gillSans12SemiBoldFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 12)!
    private static let gillSans12BoldFont: NSFont = NSFont(name: "Gill Sans Bold", size: 12)!
    
    static let gillSans13Font: NSFont = NSFont(name: "Gill Sans", size: 13)!
    static let gillSans13SemiBoldFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 13)!
    static let gillSans13LightFont: NSFont = NSFont(name: "Gill Sans Light", size: 13)!
    
    static let gillSansSemiBold10Font: NSFont = NSFont(name: "Gill Sans Semibold", size: 10)!
    static let gillSansSemiBold11Font: NSFont = NSFont(name: "Gill Sans Semibold", size: 11)!
    
    static let helpInfoTextFont: NSFont = gillSans12Font
    
    static let barModePlayingTrackTextFont: NSFont = gillSansSemiBold10Font
    
    static let regularModeTrackNameTextFont: NSFont = NSFont(name: "Gill Sans Semibold", size: 15)!
    
    static let editorHeaderTextFont: NSFont = gillSans13SemiBoldFont
    
    // Fonts used by the playlist view
    static let playlistSelectedTextFont: NSFont = gillSans12Font
    static let playlistTextFont: NSFont = gillSans12LightFont
    
    static let playlistSelectedGapTextFont: NSFont = gillSans11Font
    static let playlistGapTextFont: NSFont = gillSans11LightFont
    
    static let playlistGroupNameSelectedTextFont: NSFont = gillSans12SemiBoldFont
    static let playlistGroupNameTextFont: NSFont = gillSans12Font
    
    static let playlistGroupItemSelectedTextFont: NSFont = gillSans12Font
    static let playlistGroupItemTextFont: NSFont = gillSans12LightFont
    
    // Font used by the playlist tab view buttons
    static let tabViewButtonFont: NSFont = gillSans12Font
    static let tabViewButtonBoldFont: NSFont = gillSans12SemiBoldFont
    
    // FX tab view buttons
    static let tabViewButtonFont_small: NSFont = gillSans11Font
    static let tabViewButtonBoldFont_small: NSFont = gillSansSemiBold11Font
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = gillSans12Font
    
    // Font used by modal dialog control buttons
    static let modalDialogControlButtonFont: NSFont = gillSans11Font
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = gillSans12BoldFont
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = NSFont(name: "Gill Sans", size: 11)!
    
    // Fonts used by the track info popover view (key column and view column)
    static let popoverKeyFont: NSFont = gillSans13Font
    static let popoverValueFont: NSFont = gillSans13LightFont
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = gillSans10Font
}
