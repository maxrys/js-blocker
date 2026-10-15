
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

    struct Matrix2D {

        private var data: [
            String: [
                String: Value
            ]
        ] = [:]

        public subscript(
            _ x: String
        ) -> [String: Value]? {
            get { self.data[x] }
            set { self.data[x] = newValue }
        }

        public subscript(
            _ x: String,
            _ y: String
        ) -> Value? {
            get { self.data[x]?[y] }
            set { self.data[x, default: [:]][y] = newValue }
        }

        public subscript(
            _ x: String,
            _ y: String,
            default value: Value
        ) -> Value {
            get { self.data[x]?[y] ?? value }
            set { self.data[x, default: [:]][y] = newValue }
        }

    }

}
