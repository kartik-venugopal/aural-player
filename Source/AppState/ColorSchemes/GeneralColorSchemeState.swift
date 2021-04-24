import Foundation

/*
    Encapsulates persistent app state for a single GeneralColorScheme.
 */
class GeneralColorSchemeState: PersistentStateProtocol {
    
    var appLogoColor: ColorState?
    var backgroundColor: ColorState?
    
    var viewControlButtonColor: ColorState?
    var functionButtonColor: ColorState?
    var textButtonMenuColor: ColorState?
    var toggleButtonOffStateColor: ColorState?
    var selectedTabButtonColor: ColorState?
    
    var mainCaptionTextColor: ColorState?
    var tabButtonTextColor: ColorState?
    var selectedTabButtonTextColor: ColorState?
    var buttonMenuTextColor: ColorState?
    
    init() {}
    
    init(_ scheme: GeneralColorScheme) {
        
        self.appLogoColor = ColorState.fromColor(scheme.appLogoColor)
        self.backgroundColor = ColorState.fromColor(scheme.backgroundColor)
        
        self.viewControlButtonColor = ColorState.fromColor(scheme.viewControlButtonColor)
        self.functionButtonColor = ColorState.fromColor(scheme.functionButtonColor)
        self.textButtonMenuColor = ColorState.fromColor(scheme.textButtonMenuColor)
        self.toggleButtonOffStateColor = ColorState.fromColor(scheme.toggleButtonOffStateColor)
        self.selectedTabButtonColor = ColorState.fromColor(scheme.selectedTabButtonColor)
        
        self.mainCaptionTextColor = ColorState.fromColor(scheme.mainCaptionTextColor)
        self.tabButtonTextColor = ColorState.fromColor(scheme.tabButtonTextColor)
        self.selectedTabButtonTextColor = ColorState.fromColor(scheme.selectedTabButtonTextColor)
        self.buttonMenuTextColor = ColorState.fromColor(scheme.buttonMenuTextColor)
    }
    
    required init?(_ map: NSDictionary) -> GeneralColorSchemeState? {
        
        let state = GeneralColorSchemeState()
        
        if let colorDict = map["appLogoColor"] as? NSDictionary {
            state.appLogoColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["backgroundColor"] as? NSDictionary {
            state.backgroundColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["viewControlButtonColor"] as? NSDictionary {
            state.viewControlButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["functionButtonColor"] as? NSDictionary {
            state.functionButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["textButtonMenuColor"] as? NSDictionary {
            state.textButtonMenuColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["toggleButtonOffStateColor"] as? NSDictionary {
            state.toggleButtonOffStateColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectedTabButtonColor"] as? NSDictionary {
            state.selectedTabButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["mainCaptionTextColor"] as? NSDictionary {
            state.mainCaptionTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["tabButtonTextColor"] as? NSDictionary {
            state.tabButtonTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectedTabButtonTextColor"] as? NSDictionary {
            state.selectedTabButtonTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["buttonMenuTextColor"] as? NSDictionary {
            state.buttonMenuTextColor =  ColorState.deserialize(colorDict)
        }
        
        return state
    }
}
