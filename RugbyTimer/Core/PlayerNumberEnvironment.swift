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
    /// This match's substitution rules, for the iPhone live screen's SUB button and counts.
    @Entry var substitutionRules = SubstitutionRules()
}
