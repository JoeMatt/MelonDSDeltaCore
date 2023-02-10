//
//  MelonDS.swift
//  MelonDSDeltaCore
//
//  Created by Riley Testut on 10/31/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import Foundation
import AVFoundation

@_exported import DeltaCore
@_exported import melonDSSwift
@_exported import melonDSBridge
@_exported import melonDS

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

extension MelonDSGameInput: Input {
    public var type: InputType {
        return .game(.ds)
    }
}

public struct MelonDS: DeltaCoreProtocol {
    public static let core = MelonDS()
    
    public var name: String { "melonDS" }
    public var identifier: String { "com.rileytestut.MelonDSDeltaCore" }
    
    public var gameType: GameType { GameType.ds }
    public var gameInputType: Input.Type { MelonDSGameInput.self }
    public var gameSaveFileExtension: String { "dsv" }
    
    public let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)!
    public let videoFormat = VideoFormat(format: .bitmap(.bgra8), dimensions: CGSize(width: 256, height: 384))
    
    public var supportedCheatFormats: Set<CheatFormat> {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        return [actionReplayFormat]
    }
    
    public var emulatorBridge: EmulatorBridging { MelonDSEmulatorBridge.shared as! EmulatorBridging}
    
    private init()
    {
    }
}

// Expose DeltaCore properties to Objective-C.
public extension MelonDSEmulatorBridge
{
    @objc(dsResources) class var __dsResources: Bundle {
        return MelonDS.core.resourceBundle
    }
    
    @objc(coreDirectoryURL) class var __coreDirectoryURL: URL {
        return _coreDirectoryURL
    }
}

private let _coreDirectoryURL = MelonDS.core.directoryURL
