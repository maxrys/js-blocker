
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

final class PopupState: ObservableObject {

    enum Match: Equatable {

        case exact
        case wildcard(indices: [Int])
        case none
        case noDomain

        public var indices: [Int] {
            switch self {
                case .wildcard(let indices): return indices
                default: return []
            }
        }

        public var isExact   : Bool { self == .exact }
        public var isWildcard: Bool { if case .wildcard = self { return true } else { return false } }
        public var isNone    : Bool { self == .none }
        public var isNoDomain: Bool { self == .noDomain }

    }

    static public private(set) var shared = PopupState()

    @Published var match: Match = .none
    @Published var exactRule: String = ""
    @Published var wildcardRules: [String] = []

    private init() { /* singleton */
    }

}
