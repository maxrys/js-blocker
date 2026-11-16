
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    struct NSColorSet {
        subscript(_ color: NSColor) -> Color {
            Color(color)
        }
    }

    static let NS = NSColorSet()

    static let label: Color = {
        Self.NS[.labelColor]
    }()

    static let selectedContentBackground: Color = {
        Self.NS[.selectedContentBackgroundColor]
    }()

    static let selectedContentUnactiveBackground: Color = {
        Self.NS[.unemphasizedSelectedContentBackgroundColor]
    }()

}
