
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Cocoa

@main
class App: NSObject, NSApplicationDelegate {

    func applicationDidBecomeActive(_ notification: Notification) {
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
