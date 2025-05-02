
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Cocoa

@main class App: NSObject, NSApplicationDelegate {

    static let GROUP_NAME     = "97CZR6J379.maxrys.js-blocker"
    static let EXTENSION_NAME = "maxrys.js-blocker.extension"

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}
