
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

struct ADFetchItem: Equatable {

    let name: String
    let nameDecoded: String
    let isWildcard: Bool

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }

}
