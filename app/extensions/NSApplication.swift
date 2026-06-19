
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import os
import AppKit

extension NSApplication {

    static public var appVersion      : String? { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String }
    static public var appBuild        : String? { Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion"           ) as? String }
    static public var appCopyright    : String? { Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright"  ) as? String }
    static public var appNameLocalized: String  { Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName"       ) as? String ?? NSLocalizedString(ProcessInfo.processInfo.processName, comment: "") }
    static public var pageMarketing   : String? { Bundle.main.object(forInfoDictionaryKey: "Page Marketing"            ) as? String }
    static public var pageSupport     : String? { Bundle.main.object(forInfoDictionaryKey: "Page Support"              ) as? String }

}
