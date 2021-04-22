import Cocoa

/*
    Container for fonts used by the UI
 */
struct Fonts {
    
    // Font used in modal dialogs and utility windows.
    struct Auxiliary {
        
        static let size13: NSFont = NSFont(name: "Play Regular", size: 13)!
    }
    
    struct Standard {
        
        static let mainFont_8: NSFont = NSFont(name: "Exo-Medium", size: 8)!
        
        static let mainFont_9: NSFont = NSFont(name: "Exo-Medium", size: 9)!

        static let mainFont_10: NSFont = NSFont(name: "Exo-Medium", size: 10)!

        static let mainFont_11: NSFont = NSFont(name: "Exo-Medium", size: 11)!
        static let mainFont_11_5: NSFont = NSFont(name: "Exo-Medium", size: 11.5)!

        static let mainFont_12: NSFont = NSFont(name: "Exo-Medium", size: 12)!
        static let mainFont_12_5: NSFont = NSFont(name: "Exo-Medium", size: 12.5)!

        static let mainFont_13: NSFont = NSFont(name: "Exo-Medium", size: 13)!

        static let mainFont_14: NSFont = NSFont(name: "Exo-Medium", size: 14)!

        static let mainFont_15: NSFont = NSFont(name: "Exo-Medium", size: 15)!

        static let captionFont_13: NSFont = NSFont(name: "AlegreyaSansSC-Regular", size: 13)!
        static let captionFont_14: NSFont = NSFont(name: "AlegreyaSansSC-Regular", size: 14)!
        static let captionFont_15: NSFont = NSFont(name: "AlegreyaSansSC-Regular", size: 15)!
        static let captionFont_16: NSFont = NSFont(name: "AlegreyaSansSC-Regular", size: 16)!

        static let captionFont_18: NSFont = NSFont(name: "AlegreyaSansSC-Regular", size: 18)!
    }
    
    struct Rounded {
        
        static let mainFont_10: NSFont = NSFont(name: "FuturaBT-Light", size: 10)!
        static let mainFont_10_5: NSFont = NSFont(name: "FuturaBT-Light", size: 10.5)!
        
        static let mainFont_12: NSFont = NSFont(name: "FuturaBT-Light", size: 12)!
        static let mainFont_12_5: NSFont = NSFont(name: "FuturaBT-Light", size: 12.5)!
        
        static let mainFont_13: NSFont = NSFont(name: "FuturaBT-Light", size: 13)!
        
        static let mainFont_14: NSFont = NSFont(name: "FuturaBT-Light", size: 14)!
        
        static let mainFont_16: NSFont = NSFont(name: "FuturaBT-Light", size: 16)!
        
        static let captionFont_13: NSFont = NSFont(name: "RoundorNonCommercialRegular", size: 13)!
        static let captionFont_13_5: NSFont = NSFont(name: "RoundorNonCommercialRegular", size: 13.5)!
        
        static let captionFont_14: NSFont = NSFont(name: "RoundorNonCommercialRegular", size: 14)!
        static let captionFont_15: NSFont = NSFont(name: "RoundorNonCommercialRegular", size: 15)!
        static let captionFont_16: NSFont = NSFont(name: "RoundorNonCommercialRegular", size: 16)!
    }
    
    struct Programmer {
        
        static let mainFont_9: NSFont = NSFont(name: "Monaco", size: 9)!
        
        static let mainFont_10: NSFont = NSFont(name: "Monaco", size: 10)!
        
        static let mainFont_11: NSFont = NSFont(name: "Monaco", size: 11)!
        
        static let mainFont_12: NSFont = NSFont(name: "Monaco", size: 12)!
        static let mainFont_12_5: NSFont = NSFont(name: "Monaco", size: 12.5)!
        
        static let mainFont_14: NSFont = NSFont(name: "Monaco", size: 14)!
        
        static let captionFont_13: NSFont = NSFont(name: "CarroisGothicSC-Regular", size: 13)!
        static let captionFont_15: NSFont = NSFont(name: "CarroisGothicSC-Regular", size: 15)!
        static let captionFont_16: NSFont = NSFont(name: "CarroisGothicSC-Regular", size: 16)!
    }
    
    struct Novelist {
            
            static let mainFont_9: NSFont = NSFont(name: "ComingSoon", size: 9)!
            
            static let mainFont_11: NSFont = NSFont(name: "ComingSoon", size: 11)!
            static let mainFont_11_5: NSFont = NSFont(name: "ComingSoon", size: 11.5)!
            
            static let mainFont_12: NSFont = NSFont(name: "ComingSoon", size: 12)!
            static let mainFont_12_5: NSFont = NSFont(name: "ComingSoon", size: 12.5)!
            
            static let mainFont_13: NSFont = NSFont(name: "ComingSoon", size: 13)!
            static let mainFont_13_5: NSFont = NSFont(name: "ComingSoon", size: 13.5)!
            
            static let mainFont_15: NSFont = NSFont(name: "ComingSoon", size: 15)!
            
            static let captionFont_12: NSFont = NSFont(name: "WalterTurncoat", size: 12)!
            static let captionFont_12_5: NSFont = NSFont(name: "WalterTurncoat", size: 12.5)!
        
            static let captionFont_14: NSFont = NSFont(name: "WalterTurncoat", size: 14)!
            static let captionFont_15: NSFont = NSFont(name: "WalterTurncoat", size: 15)!
            
            static let captionFont_18: NSFont = NSFont(name: "WalterTurncoat", size: 18)!
        }
    
    struct SoySauce {
            
            static let mainFont_14: NSFont = NSFont(name: "RagingRedLotusBB", size: 14)!
            
            static let mainFont_17: NSFont = NSFont(name: "RagingRedLotusBB", size: 17)!
            
            static let mainFont_18: NSFont = NSFont(name: "RagingRedLotusBB", size: 18)!
            
            static let mainFont_20: NSFont = NSFont(name: "RagingRedLotusBB", size: 20)!
            static let mainFont_22: NSFont = NSFont(name: "RagingRedLotusBB", size: 22)!
        
            static let mainFont_25: NSFont = NSFont(name: "RagingRedLotusBB", size: 25)!
            
            static let captionFont_14: NSFont = NSFont(name: "Shufen", size: 14)!
            static let captionFont_15: NSFont = NSFont(name: "Shufen", size: 15)!
            
            static let captionFont_18: NSFont = NSFont(name: "Shufen", size: 18)!
            static let captionFont_19: NSFont = NSFont(name: "Shufen", size: 19)!
        }
    
    struct Futuristic {
            
            static let mainFont_11: NSFont = NSFont(name: "ControlFreak", size: 11)!
            
            static let mainFont_12: NSFont = NSFont(name: "ControlFreak", size: 12)!
            
            static let mainFont_13: NSFont = NSFont(name: "ControlFreak", size: 13)!
            static let mainFont_13_5: NSFont = NSFont(name: "ControlFreak", size: 13.5)!
            
            static let mainFont_14: NSFont = NSFont(name: "ControlFreak", size: 14)!
            static let mainFont_14_5: NSFont = NSFont(name: "ControlFreak", size: 14.5)!
            
            static let mainFont_15: NSFont = NSFont(name: "ControlFreak", size: 15)!
            static let mainFont_15_5: NSFont = NSFont(name: "ControlFreak", size: 15.5)!
            
            static let mainFont_16: NSFont = NSFont(name: "ControlFreak", size: 16)!
            static let mainFont_16_5: NSFont = NSFont(name: "ControlFreak", size: 16.5)!
            
            static let mainFont_19: NSFont = NSFont(name: "ControlFreak", size: 19)!
            
            static let captionFont_14: NSFont = NSFont(name: "neo-latina", size: 14)!
            static let captionFont_15: NSFont = NSFont(name: "neo-latina", size: 15)!
            
            static let captionFont_18: NSFont = NSFont(name: "neo-latina", size: 18)!
            static let captionFont_19: NSFont = NSFont(name: "neo-latina", size: 19)!
        }
    
    struct Gothic {
        
            static let mainFont_9: NSFont = NSFont(name: "Metamorphous", size: 9)!
            
            static let mainFont_10: NSFont = NSFont(name: "Metamorphous", size: 10)!
            
            static let mainFont_11: NSFont = NSFont(name: "Metamorphous", size: 11)!
            static let mainFont_11_5: NSFont = NSFont(name: "Metamorphous", size: 11.5)!
            
            static let mainFont_12: NSFont = NSFont(name: "Metamorphous", size: 12)!
            static let mainFont_12_5: NSFont = NSFont(name: "Metamorphous", size: 12.5)!
            
            static let mainFont_14: NSFont = NSFont(name: "Metamorphous", size: 14)!
            
            static let captionFont_14: NSFont = NSFont(name: "AlmendraSC-Regular", size: 14)!
            static let captionFont_17: NSFont = NSFont(name: "AlmendraSC-Regular", size: 17)!
        }
    
    struct Papyrus {
        
        static let mainFont_9: NSFont = NSFont(name: "Papyrus", size: 9)!
        
        static let mainFont_11: NSFont = NSFont(name: "Papyrus", size: 11)!
        
        static let mainFont_12: NSFont = NSFont(name: "Papyrus", size: 12)!
        
        static let mainFont_13: NSFont = NSFont(name: "Papyrus", size: 13)!
        static let mainFont_13_5: NSFont = NSFont(name: "Papyrus", size: 13.5)!
        
        static let mainFont_14: NSFont = NSFont(name: "Papyrus", size: 14)!
        static let mainFont_14_5: NSFont = NSFont(name: "Papyrus", size: 14.5)!
        
        static let mainFont_15: NSFont = NSFont(name: "Papyrus", size: 15)!
        
        static let mainFont_16: NSFont = NSFont(name: "Papyrus", size: 16)!
        static let mainFont_16_5: NSFont = NSFont(name: "Papyrus", size: 16.5)!
        
        static let captionFont_10: NSFont = NSFont(name: "Aniron", size: 10)!
        static let captionFont_11: NSFont = NSFont(name: "Aniron", size: 11)!
        static let captionFont_12: NSFont = NSFont(name: "Aniron", size: 12)!
        static let captionFont_12_5: NSFont = NSFont(name: "Aniron", size: 12.5)!
    }
    
    struct PoolsideFM {

        static let mainFont_9: NSFont = NSFont(name: "ChicagoFLF", size: 9)!

        static let mainFont_10: NSFont = NSFont(name: "ChicagoFLF", size: 10)!

        static let mainFont_11: NSFont = NSFont(name: "ChicagoFLF", size: 11)!

        static let mainFont_12: NSFont = NSFont(name: "ChicagoFLF", size: 12)!
        static let mainFont_12_5: NSFont = NSFont(name: "ChicagoFLF", size: 12.5)!

        static let mainFont_14: NSFont = NSFont(name: "ChicagoFLF", size: 14)!

        static let captionFont_13: NSFont = NSFont(name: "ChicagoFLF", size: 13)!
        static let captionFont_13_5: NSFont = NSFont(name: "ChicagoFLF", size: 13.5)!
        
        static let captionFont_15: NSFont = NSFont(name: "ChicagoFLF", size: 15)!
        static let captionFont_16: NSFont = NSFont(name: "ChicagoFLF", size: 16)!
    }
    
    static let menuFont: NSFont = Standard.mainFont_11

    static let stringInputPopoverFont: NSFont = Standard.mainFont_12_5
    static let stringInputPopoverErrorFont: NSFont = Standard.mainFont_11_5
    
    static let largeTabButtonFont: NSFont = Standard.captionFont_14
    
    static let helpInfoTextFont: NSFont = Standard.mainFont_12
    
    static let editorTableHeaderTextFont: NSFont = Standard.mainFont_13
    static let editorTableTextFont: NSFont = Standard.mainFont_12
    static let editorTableSelectedTextFont: NSFont = Standard.mainFont_12
    
    // Font used by the playlist tab view buttons
    static let tabViewButtonFont: NSFont = Standard.mainFont_12
    static let tabViewButtonBoldFont: NSFont = Standard.mainFont_12
    
    // Font used by modal dialog buttons
    static let modalDialogButtonFont: NSFont = Standard.mainFont_12
    
    // Font used by modal dialog control buttons
    static let modalDialogControlButtonFont: NSFont = Standard.mainFont_11
    
    // Font used by the search modal dialog navigation buttons
    static let modalDialogNavButtonFont: NSFont = Standard.mainFont_12
    
    // Font used by modal dialog check and radio buttons
    static let checkRadioButtonFont: NSFont = Standard.mainFont_11
    
    // Font used by the popup menus
    static let popupMenuFont: NSFont = Standard.mainFont_10
}
