
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

enum BlockingType {

    case local
    case global
    case none

    var isAllowed: Bool {
        return self == .local ||
               self == .global
    }

}
