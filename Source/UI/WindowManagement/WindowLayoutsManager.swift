//
//  WindowLayoutsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayoutsManager: MappedPresets<WindowLayout> {
    
    private let viewPreferences: ViewPreferences
    
    init(persistentState: WindowLayoutsPersistentState?, viewPreferences: ViewPreferences) {
        
        self.viewPreferences = viewPreferences
        
        let systemDefinedLayouts = WindowLayoutPresets.allCases.map {$0.layout(gap: CGFloat(viewPreferences.windowGap))}
        let userDefinedLayouts: [WindowLayout] = persistentState?.userLayouts?.compactMap
        {WindowLayout(persistentState: $0)} ?? []
        
        super.init(systemDefinedPresets: systemDefinedLayouts, userDefinedPresets: userDefinedLayouts)
    }
    
    var defaultLayout: WindowLayout {
        systemDefinedPreset(named: WindowLayoutPresets.verticalFullStack.name)!
    }
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedPresets.forEach {WindowLayoutPresets.recompute(layout: $0, gap: CGFloat(viewPreferences.windowGap))}
    }
}
