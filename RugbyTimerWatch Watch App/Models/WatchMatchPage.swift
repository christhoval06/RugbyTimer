nonisolated enum WatchMatchPage: Hashable {
    enum Side: Hashable { case away, home }
    enum Action: Hashable { case score, penalties, sanctions, substitutions, injuries }

    case substitutions, sanctions, penalties, clock, score, result
    case team(Side, Action)

    static func extended(isPlaying: Bool, showsDiscipline: Bool, showsSubstitutions: Bool) -> [Self] {
        var actions: [Action] = []
        if isPlaying {
            actions.append(.score)
            if showsDiscipline { actions += [.penalties, .sanctions] }
        }
        if showsSubstitutions { actions.append(.substitutions) }
        if isPlaying { actions.append(.injuries) }

        let away = actions.reversed().map { Self.team(.away, $0) }
        let home = actions.map { Self.team(.home, $0) }
        return away + [.clock] + home
    }
}
