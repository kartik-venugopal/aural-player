//
//  MKExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
//
//  Extensions.swift
//  Castle
//
//  Created by Nicholas Hurden on 22/02/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Foundation

precedencegroup FunctorPrecedence {
    associativity: left
    higherThan: DefaultPrecedence
}

infix operator <^> : FunctorPrecedence

func <^><T, U>(f: (T) -> U, ap: T?) -> U? {
    return ap.map(f)
}
