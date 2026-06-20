
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    struct FieldSearchColorSet {
        public let background                = Color("color FieldSearch Background")
        public let icon                      = Color.label.opacity(0.3)
        public let buttonReset               = Color.label.opacity(0.3)
        public let buttonResetBackground     = Color.white
        public let buttonResetBackgroundDark = Color.black.opacity(0.3)
    }

    static let fieldSearch = FieldSearchColorSet()

}
