
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

extension View {

    func color(_ color: Color) -> some View {
        if #available(macOS 14.0, iOS 17.0, *) { return self.foregroundStyle(color) }
        else                                   { return self.foregroundColor(color) }
    }

    @inlinable nonisolated public func onHoverCursor(isEnabled: Bool = true) -> some View {
        self.onHover { isInView in
            if (isEnabled) {
                if (isInView) { NSCursor.pointingHand.push() }
                else          { NSCursor.pop() }
            }   else          { NSCursor.pop() }
        }
    }

}
