
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

final class ThisAppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaultsState.isAppLaunchedOnce_direct = true
        Migrations.migration_001()
    }

    func applicationShouldHandleReopen(_ app: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = NSWindow.get(ThisApp.WINDOW_MAIN_ID) {
            window.show()
        }
        return true
    }

    func applicationSupportsSecureRestorableState       (_    app: NSApplication) -> Bool { true }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

}

@main struct ThisApp: App {

    static let WINDOW_MAIN_TITLE_LOCALIZED = NSLocalizedString("JS Blocker", comment: "")
    static let WINDOW_MAIN_ID = "main"
    static let WINDOW_ABOUT_TITLE_LOCALIZED = String(format: NSLocalizedString("About %@" , comment: ""), NSApplication.appNameLocalized)
    static let WINDOW_ABOUT_ID = "about"

    @NSApplicationDelegateAdaptor(ThisAppDelegate.self) var appDelegate

    @StateObject private var userDefaultsState = UserDefaultsState.shared

    public var body: some Scene {
        if #available(macOS 13.0, *) {
            return Group {
                Window(Self.WINDOW_MAIN_TITLE_LOCALIZED, id: Self.WINDOW_MAIN_ID) { MainScene() }
                    .commands { self.menuCommand_showAbout }
            }
        } else {
            return Group {
                WindowGroup { MainScene() }
                    .commands { self.menuCommand_showAbout }
            }
        }
    }

    private var menuCommand_showAbout: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(Self.WINDOW_ABOUT_TITLE_LOCALIZED) {
                if let windowAbout = NSWindow.customWindows[Self.WINDOW_ABOUT_ID] {
                    windowAbout.show()
                } else {
                    _ = NSWindow.makeNewOrShowExisting(
                        ID   : Self.WINDOW_ABOUT_ID,
                        title: Self.WINDOW_ABOUT_TITLE_LOCALIZED,
                        size: CGSize(width: 300, height: 100),
                        delegate: self.appDelegate,
                        view: About()
                    )
                }
            }
        }
    }

}
