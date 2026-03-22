
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

final class ThisAppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaultsState.isAppLaunchedOnce_direct = true
    }

    func applicationSupportsSecureRestorableState       (_    app: NSApplication) -> Bool { true }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

}

@main struct ThisApp: App {

    @NSApplicationDelegateAdaptor(ThisAppDelegate.self) var appDelegate

    @StateObject private var adState = ADState.shared
    @StateObject private var userDefaultsState = UserDefaultsState.shared

    public var body: some Scene {
        WindowGroup {
            MainScene()
                .frame(minWidth: 400, minHeight: 400)
                .environmentObject(self.adState)
                .environmentObject(self.userDefaultsState)
                .onAppBecomeForeground {
                    self.adState.reload()
                }
        }
        .environment(\.layoutDirection, .leftToRight)
        .commands {
            CommandMenu("Experimental", content: {
                Button {
                    self.userDefaultsState.icloudStatus.toggle()
                } label: {
                    Text("Enable CloudKit")
                    if (self.userDefaultsState.icloudStatus) {
                        Image(systemName: "checkmark")
                    }
                }
            })
        }
    }

}
