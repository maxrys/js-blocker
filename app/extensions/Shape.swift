
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Shape {

    @ViewBuilder func fillGradientPolyfill(_ color: Color) -> some View {
        if #available(macOS 13.0, *) { self.fill(color.gradient) }
        else                         { self.fill(color) }
    }

}
