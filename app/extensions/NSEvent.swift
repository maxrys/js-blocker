
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import AppKit

extension NSEvent {

    static var isPressedCommandButton: Bool {
        Self.modifierFlags.contains(.command)
    }

    static var isPressedShiftButton: Bool {
        Self.modifierFlags.contains(.shift)
    }

    static var isPressedLeftMouseButton: Bool {
        (Self.pressedMouseButtons & 1) != 0
    }

    static var isPressedMiddleMouseButton: Bool {
        (Self.pressedMouseButtons & 4) != 0
    }

    static var isPressedRightMouseButton: Bool {
        (Self.pressedMouseButtons & 2) != 0
    }

}
