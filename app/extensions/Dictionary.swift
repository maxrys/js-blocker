
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

extension Dictionary {

    public enum OrderBy {
        case keyAscending
        case keyDescending
        case valueAscending
        case valueDescending
    }

    public func sorted(
        order: Self.OrderBy = .keyAscending
    ) -> [Element] where Key: Comparable, Value: Comparable {
        self.sorted(by: { (lhs, rhs) in
            switch order {
                case .keyAscending   : lhs.key   < rhs.key
                case .keyDescending  : lhs.key   > rhs.key
                case .valueAscending : lhs.value < rhs.value
                case .valueDescending: lhs.value > rhs.value
            }
        })
    }

}
