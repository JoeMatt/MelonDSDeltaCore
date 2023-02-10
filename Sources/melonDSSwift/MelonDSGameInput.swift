//
//  MelonDS.swift
//  MelonDSDeltaCore
//
//  Created by Riley Testut on 10/31/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore

#if !STATIC_LIBRARY
public extension GameType
{
    static let ds = GameType("com.rileytestut.delta.game.ds")
}

public extension CheatType
{
    static let actionReplay = CheatType("ActionReplay")
}
#endif

@objc public enum MelonDSGameInput: Int, _Input
{
    case a = 1
    case b = 2
    case select = 4
    case start = 8
    case right = 16
    case left = 32
    case up = 64
    case down = 128
    case r = 256
    case l = 512
    case x = 1024
    case y = 2048
    
    case touchScreenX = 4096
    case touchScreenY = 8192
    
    case lid = 16_384

    public var isContinuous: Bool {
        switch self
        {
        case .touchScreenX, .touchScreenY: return true
        default: return false
        }
    }
}
