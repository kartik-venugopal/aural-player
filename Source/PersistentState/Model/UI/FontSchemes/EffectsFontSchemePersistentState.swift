import Foundation

/*
    Encapsulates persistent app state for a single EffectsFontScheme.
 */
class EffectsFontSchemePersistentState: PersistentStateProtocol {

    var unitCaptionSize: CGFloat?
    var unitFunctionSize: CGFloat?
    var masterUnitFunctionSize: CGFloat?
    var filterChartSize: CGFloat?
    var auRowTextYOffset: CGFloat?

    init() {}

    init(_ scheme: EffectsFontScheme) {

        self.unitCaptionSize = scheme.unitCaptionFont.pointSize
        self.unitFunctionSize = scheme.unitFunctionFont.pointSize
        self.masterUnitFunctionSize = scheme.masterUnitFunctionFont.pointSize
        self.filterChartSize = scheme.filterChartFont.pointSize
        self.auRowTextYOffset = scheme.auRowTextYOffset
    }

    required init?(_ map: NSDictionary) {
        
        self.unitCaptionSize = map.cgFloatValue(forKey: "unitCaptionSize")
        self.unitFunctionSize = map.cgFloatValue(forKey: "unitFunctionSize")
        self.masterUnitFunctionSize = map.cgFloatValue(forKey: "masterUnitFunctionSize")
        self.filterChartSize = map.cgFloatValue(forKey: "filterChartSize")
        self.auRowTextYOffset = map.cgFloatValue(forKey: "auRowTextYOffset")
    }
}
