
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum FieldSearchColorSet {
        static let background                = Color("color FieldSearch Background")
        static let icon                      = Color.label.opacity(0.3)
        static let buttonReset               = Color.label.opacity(0.3)
        static let buttonResetBackground     = Color.white
        static let buttonResetBackgroundDark = Color.black.opacity(0.3)
    }

    static let fieldSearch = FieldSearchColorSet.self

}
