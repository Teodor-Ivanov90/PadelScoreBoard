nonisolated struct Play: Codable {
    enum MaxSets: Int, Codable {
        case three = 3
        case five = 5
    }
    
    enum Side: String, Codable, Hashable {
        case lhs
        case rhs
        
        var other: Self {
            self == .lhs ? .rhs : .lhs
        }
    }
    
    struct Score: Codable {
        enum Points: Codable, Equatable {
            case standard(points: StandardPoints)
            case tiebreak(points: Int)
            
            var displayValue: String {
                    switch self {
                    case .standard(points: let standardPoints):
                        return standardPoints.rawValue
                    case .tiebreak(points: let points):
                        return String(points)
                    }
                }
        }
        
        enum StandardPoints: String, Codable {
            case love = "0"
            case fifteen = "15"
            case thirty = "30"
            case forty = "40"
            case advantage = "A"
        }
        
        var points: Points
        var games: Int
        var sets: Int
        
    }
    
    let maxSets: MaxSets
    var lhsScore: Score
    var rhsScore: Score
    var serve: Side
    var servePosition: Side
    var isPlayFinished: Bool {
        Double(lhsScore.sets) > (Double(maxSets.rawValue) / 2.0) ||
        Double(rhsScore.sets) > (Double(maxSets.rawValue) / 2.0)
    }
    
    var lhsTeamHasWon: String {
        if Double(lhsScore.sets) > (Double(maxSets.rawValue) / 2.0) {
            return "Blue team has won the game"
        } else {
            return "Red team has won the game"
        }
    }
    
    mutating func lhsTeamScored() {
        incrementPoints(of: .lhs)
        
    }
    
    mutating func rhsTeamScored() {
        incrementPoints(of: .rhs)
    }
    
    mutating func restart() {
        self = .init(
            maxSets: maxSets
        )
    }
    
    init(
        maxSets: MaxSets = .three,
        lhsScore: Score = .init(points: .standard(points: .love), games: 0, sets: 0),
        rhsScore: Score = .init(points: .standard(points: .love), games: 0, sets: 0),
        serve: Side = .lhs,
        servePosition: Side = .rhs
    ) {
        self.maxSets = maxSets
        self.lhsScore = lhsScore
        self.rhsScore = rhsScore
        self.serve = serve
        self.servePosition = servePosition
    }
    
    subscript(score side: Side) -> Score {
        get {
            side == .lhs ? lhsScore : rhsScore
        }
        
        set {
            if side == .lhs {
                lhsScore = newValue
            } else {
                rhsScore = newValue
            }
        }
    }
    
    mutating func incrementPoints(
        of side: Side
    ) {
        servePosition = servePosition.other
        
        switch (self[score: side].points, self[score: side.other].points) {

        case let (.tiebreak(points: myPoints), .tiebreak(points: opponentPoints)):
            let sum = myPoints + opponentPoints
            if sum.isMultiple(of: 2) {
                serve = serve.other
            }
        default:
            break
        }
        
        switch self[score: side].points {
        case .standard(points: .love):
            self[score: side].points = .standard(points: .fifteen)
        case .standard(points: .fifteen):
            self[score: side].points = .standard(points: .thirty)
        case .standard(points: .thirty):
            self[score: side].points = .standard(points: .forty)
        case .standard(points: .forty):
            switch self[score: side.other].points {
            case .standard(points: .forty):
                self[score: side].points = .standard(points: .advantage)
            case .standard(points: .advantage):
                self[score: side].points = .standard(points: .forty)
                self[score: side.other].points = .standard(points: .forty)
            default:
                incrementGames(of: side)
            }
        case .standard(points: .advantage):
            incrementGames(of: side)
            
        case .tiebreak(points: let points):
            switch points {
            case ...5:
                self[score: side].points = .tiebreak(points: points + 1)
            case 6...:
                switch self[score: side.other].points {
                case .tiebreak(points: let opponentPoints):
                    switch opponentPoints {
                    case ...5:
                        incrementGames(of: side)
                    case 6...:
                        if (points - opponentPoints) >= 1 {
                            incrementGames(of: side)
                        } else {
                            self[score: side].points = .tiebreak(points: points + 1)
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            default:
                break
            }
        }
    }

    mutating func incrementGames(
        of side: Side
    ) {
        var nextGamePoints: Play.Score.Points = .standard(points: .love)
        switch (self[score: side].games, self[score: side.other].games) {
        case (...4, _):
            self[score: side].games += 1
        case (5, ...4):
            incrementSets(of: side)
        case (5, 5):
            self[score: side].games += 1
        case (5, 6):
            self[score: side].games += 1
            nextGamePoints = .tiebreak(points: 0)
        case (6, _):
            incrementSets(of: side)
        default:
            fatalError()
        }
        
        self[score: side].points = nextGamePoints
        self[score: side.other].points = nextGamePoints
        self.serve = serve.other
        self.servePosition = .rhs
    }

    mutating func incrementSets(
        of side: Side
    ) {
        self[score: side].sets += 1
        self[score: side].games = 0
        self[score: side.other].games = 0
    }
    
    func scoreAnnounce() -> String {
        switch (self[score: .lhs].points, self[score: .rhs].points) {
        case(.standard(points: .forty), .standard(points: .forty)):
            return "Deuce"
        case(.standard(points: .advantage), _):
            return "Advantage blue team"
        case(_, .standard(points: .advantage)):
            return "Advantage red team"
        default:
            let lhsPoints = self[score: .lhs].points.displayValue
            let rhsPoints = self[score: .rhs].points.displayValue
            
            if lhsPoints == rhsPoints {
                return "\(lhsPoints) all"
            } else {
                return self.serve == .lhs ? "\(lhsPoints) \(rhsPoints)" : "\(rhsPoints) \(lhsPoints)"
            }
        }
    }
}
