
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

enum MatchType {

    case exact
    case wildcard
    case none

    var isAllowedJS: Bool {
        return self == .exact ||
               self == .wildcard
    }

}
