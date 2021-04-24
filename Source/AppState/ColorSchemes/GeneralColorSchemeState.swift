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
    
    required init?(_ map: NSDictionary) {
        
        if let colorDict = map["appLogoColor"] as? NSDictionary {
            self.appLogoColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["backgroundColor"] as? NSDictionary {
            self.backgroundColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["viewControlButtonColor"] as? NSDictionary {
            self.viewControlButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["functionButtonColor"] as? NSDictionary {
            self.functionButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["textButtonMenuColor"] as? NSDictionary {
            self.textButtonMenuColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["toggleButtonOffStateColor"] as? NSDictionary {
            self.toggleButtonOffStateColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectedTabButtonColor"] as? NSDictionary {
            self.selectedTabButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["mainCaptionTextColor"] as? NSDictionary {
            self.mainCaptionTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["tabButtonTextColor"] as? NSDictionary {
            self.tabButtonTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectedTabButtonTextColor"] as? NSDictionary {
            self.selectedTabButtonTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["buttonMenuTextColor"] as? NSDictionary {
            self.buttonMenuTextColor =  ColorState.deserialize(colorDict)
        }
    }
}
