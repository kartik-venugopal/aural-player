//
//  GesturePressType.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

///
/// Enumerates the types of touch gestures that can be performed
/// on a trackpad / MagicMouse / iOS device.
///
enum GesturePressType {
    
    /// No gesture.
    case none
    
    /// A zoom / magnification gesture.
    case pinch
    
    /// A scroll / pan gesture.
    case pan
}
