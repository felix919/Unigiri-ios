import Foundation

enum AttackType: Hashable {
    case day
    case night
}

struct SearchCondition {
    var rare: Set<String> = []
    var cardType: Set<String> = []
    var type: Set<String> = []
    var power: Set<Int> = []
    var pack: String?
    var song: String?
    var attackEnabled = false
    var attackType: Set<AttackType> = []
    var attackRange: ClosedRange<Int> = 0...250
}
