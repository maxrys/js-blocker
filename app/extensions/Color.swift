
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
        Color(NSColor.labelColor)
    }()

    static let selectedContentBackground: Color = {
        Color(NSColor.selectedContentBackgroundColor)
    }()

    static let selectedContentUnactiveBackground: Color = {
        Color(NSColor.unemphasizedSelectedContentBackgroundColor)
    }()

}
