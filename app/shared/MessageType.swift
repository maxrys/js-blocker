
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Cocoa
import SwiftUI

enum MessageType: Int {

    static let COLORNAME_TEXT                           = "color Message Text"
    static let COLORNAME_INFO_TITLE_BACKGROUND          = "color Message Info Title Background"
    static let COLORNAME_INFO_DESCRIPTION_BACKGROUND    = "color Message Info Description Background"
    static let COLORNAME_OK_TITLE_BACKGROUND            = "color Message Ok Title Background"
    static let COLORNAME_OK_DESCRIPTION_BACKGROUND      = "color Message Ok Description Background"
    static let COLORNAME_WARNING_TITLE_BACKGROUND       = "color Message Warning Title Background"
    static let COLORNAME_WARNING_DESCRIPTION_BACKGROUND = "color Message Warning Description Background"
    static let COLORNAME_ERROR_TITLE_BACKGROUND         = "color Message Error Title Background"
    static let COLORNAME_ERROR_DESCRIPTION_BACKGROUND   = "color Message Error Description Background"

    case info
    case ok
    case warning
    case error

    var colorNSTitleBackground: NSColor {
        switch self {
            case .info   : return NSColor(named: Self.COLORNAME_INFO_TITLE_BACKGROUND   ) ?? .systemPurple
            case .ok     : return NSColor(named: Self.COLORNAME_OK_TITLE_BACKGROUND     ) ?? .systemGreen
            case .warning: return NSColor(named: Self.COLORNAME_WARNING_TITLE_BACKGROUND) ?? .systemYellow
            case .error  : return NSColor(named: Self.COLORNAME_ERROR_TITLE_BACKGROUND  ) ?? .systemRed
        }
    }

    var colorNSDescriptionBackground: NSColor {
        switch self {
            case .info   : return NSColor(named: Self.COLORNAME_INFO_DESCRIPTION_BACKGROUND   ) ?? .systemGray
            case .ok     : return NSColor(named: Self.COLORNAME_OK_DESCRIPTION_BACKGROUND     ) ?? .systemGray
            case .warning: return NSColor(named: Self.COLORNAME_WARNING_DESCRIPTION_BACKGROUND) ?? .systemGray
            case .error  : return NSColor(named: Self.COLORNAME_ERROR_DESCRIPTION_BACKGROUND  ) ?? .systemGray
        }
    }

    var colorTitleBackground: Color {
        switch self {
            case .info   : return Color(Self.COLORNAME_INFO_TITLE_BACKGROUND)
            case .ok     : return Color(Self.COLORNAME_OK_TITLE_BACKGROUND)
            case .warning: return Color(Self.COLORNAME_WARNING_TITLE_BACKGROUND)
            case .error  : return Color(Self.COLORNAME_ERROR_TITLE_BACKGROUND)
        }
    }

    var colorDescriptionBackground: Color {
        switch self {
            case .info   : return Color(Self.COLORNAME_INFO_DESCRIPTION_BACKGROUND)
            case .ok     : return Color(Self.COLORNAME_OK_DESCRIPTION_BACKGROUND)
            case .warning: return Color(Self.COLORNAME_WARNING_DESCRIPTION_BACKGROUND)
            case .error  : return Color(Self.COLORNAME_ERROR_DESCRIPTION_BACKGROUND)
        }
    }

}
