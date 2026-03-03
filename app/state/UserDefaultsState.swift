
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

final class UserDefaultsState: ObservableObject {

    static public private(set) var shared = UserDefaultsState()

    static var isAppLaunchedOnce_direct: Bool {
        get { UserDefaults(suiteName: GROUP_NAME)?.bool(forKey: "isAppLaunchedOnce") ?? false }
        set { UserDefaults(suiteName: GROUP_NAME)?.set(newValue, forKey: "isAppLaunchedOnce") }
    }

    static var icloudStatus_direct: Bool {
        get { UserDefaults(suiteName: GROUP_NAME)?.bool(forKey: "icloudStatus") ?? false }
        set { UserDefaults(suiteName: GROUP_NAME)?.set(newValue, forKey: "icloudStatus") }
    }

    @AppStorage("icloudStatus", store: UserDefaults(suiteName: GROUP_NAME))
        var icloudStatus: Bool = false { didSet {
            AllowedDomains.containerInit()
        }}

    private init() { /* singleton */
    }

}
