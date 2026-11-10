//
//  CoinTossService.swift
//  RugbyTimer
//

import Foundation

/// Flips the coin. The random source is injected so tests can fix the outcome.
public struct CoinTossService {
    private let flipCoin: () -> CoinFace

    public init(flipCoin: @escaping () -> CoinFace = { Bool.random() ? .heads : .tails }) {
        self.flipCoin = flipCoin
    }

    public func flip() -> CoinFace { flipCoin() }
}
