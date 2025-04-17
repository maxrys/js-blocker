
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Cocoa

@main class App: NSObject, NSApplicationDelegate {

    static let GROUP_NAME           = "97CZR6J379.maxrys.js-blocker"
    static let NAME                 = "maxrys.js-blocker"
    static let POPUP_EXTENSION_NAME = "maxrys.js-blocker.extension"
    static let RULES_EXTENSION_NAME = "maxrys.js-blocker.rules"

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
