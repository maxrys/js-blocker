
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Cocoa

@main class App: NSObject, NSApplicationDelegate {

    static let GROUP_NAME         = "97CZR6J379.maxrys.js-blocker"
    static let EXTENSION_NAME     = "maxrys.js-blocker.extension"
    static let STORAGE_NAME       = "JSBlocker.sqlite"
    static let STORAGE_CLOUD_NAME = "iCloud.jsblocker"

    @IBOutlet var menuItem_isCloudEnabled: NSMenuItem!

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: App.GROUP_NAME)
    }

    static var isCloudEnabled: Bool {
        get { Self.userDefaults?.bool(forKey: "isCloudEnabled") ?? false }
        set { Self.userDefaults?.set(newValue, forKey: "isCloudEnabled") }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        self.menuItem_isCloudEnabled.state = Self.isCloudEnabled ? .on : .off
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func onClick_menuItem_enableCloudKit(_ menuItem: NSMenuItem) {
        Self.isCloudEnabled.toggle()
        menuItem.state = Self.isCloudEnabled ? .on : .off
        WhiteDomains.containerInit()
    }

}
