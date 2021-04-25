import Foundation

/*
    Encapsulates persistent app state for a single GeneralColorScheme.
 */
class GeneralColorSchemePersistentState: PersistentStateProtocol {
    
    var appLogoColor: ColorPersistentState?
    var backgroundColor: ColorPersistentState?
    
    var viewControlButtonColor: ColorPersistentState?
    var functionButtonColor: ColorPersistentState?
    var textButtonMenuColor: ColorPersistentState?
    var toggleButtonOffStateColor: ColorPersistentState?
    var selectedTabButtonColor: ColorPersistentState?
    
    var mainCaptionTextColor: ColorPersistentState?
    var tabButtonTextColor: ColorPersistentState?
    var selectedTabButtonTextColor: ColorPersistentState?
    var buttonMenuTextColor: ColorPersistentState?
    
    init() {}
    
    init(_ scheme: GeneralColorScheme) {
        
        self.appLogoColor = ColorPersistentState.fromColor(scheme.appLogoColor)
        self.backgroundColor = ColorPersistentState.fromColor(scheme.backgroundColor)
        
        self.viewControlButtonColor = ColorPersistentState.fromColor(scheme.viewControlButtonColor)
        self.functionButtonColor = ColorPersistentState.fromColor(scheme.functionButtonColor)
        self.textButtonMenuColor = ColorPersistentState.fromColor(scheme.textButtonMenuColor)
        self.toggleButtonOffStateColor = ColorPersistentState.fromColor(scheme.toggleButtonOffStateColor)
        self.selectedTabButtonColor = ColorPersistentState.fromColor(scheme.selectedTabButtonColor)
        
        self.mainCaptionTextColor = ColorPersistentState.fromColor(scheme.mainCaptionTextColor)
        self.tabButtonTextColor = ColorPersistentState.fromColor(scheme.tabButtonTextColor)
        self.selectedTabButtonTextColor = ColorPersistentState.fromColor(scheme.selectedTabButtonTextColor)
        self.buttonMenuTextColor = ColorPersistentState.fromColor(scheme.buttonMenuTextColor)
    }
    
    required init?(_ map: NSDictionary) {
        
        self.appLogoColor =  map.colorValue(forKey: "appLogoColor")
        self.backgroundColor =  map.colorValue(forKey: "backgroundColor")
        self.viewControlButtonColor =  map.colorValue(forKey: "viewControlButtonColor")
        self.functionButtonColor =  map.colorValue(forKey: "functionButtonColor")
        self.textButtonMenuColor =  map.colorValue(forKey: "textButtonMenuColor")
        self.toggleButtonOffStateColor =  map.colorValue(forKey: "toggleButtonOffStateColor")
        self.selectedTabButtonColor =  map.colorValue(forKey: "selectedTabButtonColor")
        self.mainCaptionTextColor =  map.colorValue(forKey: "mainCaptionTextColor")
        self.tabButtonTextColor =  map.colorValue(forKey: "tabButtonTextColor")
        self.selectedTabButtonTextColor =  map.colorValue(forKey: "selectedTabButtonTextColor")
        self.buttonMenuTextColor =  map.colorValue(forKey: "buttonMenuTextColor")
    }
}
