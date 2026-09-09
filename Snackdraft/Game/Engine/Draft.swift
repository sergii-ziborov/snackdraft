import Foundation

enum Draft {
    static func deal(level: LevelDef, seed: UInt64, turn: Int) -> [SnackID] {
        var rng = SeededRNG(seed: seed &+ UInt64(turn &+ 1) &* 7919)
        var bag: [SnackID] = []
        for snack in level.pool {
            let copies = level.weight(for: snack)
            bag.append(contentsOf: Array(repeating: snack, count: copies))
        }
        rng.shuffle(&bag)

        var offer: [SnackID] = []
        for snack in bag where !offer.contains(snack) {
            offer.append(snack)
            if offer.count == 3 { break }
        }

        if offer.count < 3 {
            let extras = SnackID.allCases.filter { !offer.contains($0) }
            for snack in extras {
                offer.append(snack)
                if offer.count == 3 { break }
            }
        }
        return offer
    }
}
