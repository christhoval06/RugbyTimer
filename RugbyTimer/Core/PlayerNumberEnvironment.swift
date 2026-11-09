//
//  PlayerNumberEnvironment.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/09/26.
//

import SwiftUI

extension EnvironmentValues {
    /// Shirt numbers the referee can pick, set from the iPhone's player range setting.
    @Entry var playerNumberRange: ClosedRange<Int> = MatchEvent.playerNumbers
}
