
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Cocoa
import SwiftUI

enum MessageType: Int {

    enum ColorNames: String {
        case text                         = "color Message Text"
        case infoTitleBackground          = "color Message Info Title Background"
        case infoDescriptionBackground    = "color Message Info Description Background"
        case okTitleBackground            = "color Message Ok Title Background"
        case okDescriptionBackground      = "color Message Ok Description Background"
        case warningTitleBackground       = "color Message Warning Title Background"
        case warningDescriptionBackground = "color Message Warning Description Background"
        case errorTitleBackground         = "color Message Error Title Background"
        case errorDescriptionBackground   = "color Message Error Description Background"
    }

    case info
    case ok
    case warning
    case error

    var colorNSTitleBackground: NSColor {
        switch self {
            case .info   : NSColor(named: Self.ColorNames.infoTitleBackground.rawValue   ) ?? .systemPurple
            case .ok     : NSColor(named: Self.ColorNames.okTitleBackground.rawValue     ) ?? .systemGreen
            case .warning: NSColor(named: Self.ColorNames.warningTitleBackground.rawValue) ?? .systemYellow
            case .error  : NSColor(named: Self.ColorNames.errorTitleBackground.rawValue  ) ?? .systemRed
        }
    }

    var colorNSDescriptionBackground: NSColor {
        switch self {
            case .info   : NSColor(named: Self.ColorNames.infoDescriptionBackground.rawValue   ) ?? .systemGray
            case .ok     : NSColor(named: Self.ColorNames.okDescriptionBackground.rawValue     ) ?? .systemGray
            case .warning: NSColor(named: Self.ColorNames.warningDescriptionBackground.rawValue) ?? .systemGray
            case .error  : NSColor(named: Self.ColorNames.errorDescriptionBackground.rawValue  ) ?? .systemGray
        }
    }

    var colorTitleBackground: Color {
        switch self {
            case .info   : Color(Self.ColorNames.infoTitleBackground.rawValue)
            case .ok     : Color(Self.ColorNames.okTitleBackground.rawValue)
            case .warning: Color(Self.ColorNames.warningTitleBackground.rawValue)
            case .error  : Color(Self.ColorNames.errorTitleBackground.rawValue)
        }
    }

    var colorDescriptionBackground: Color {
        switch self {
            case .info   : Color(Self.ColorNames.infoDescriptionBackground.rawValue)
            case .ok     : Color(Self.ColorNames.okDescriptionBackground.rawValue)
            case .warning: Color(Self.ColorNames.warningDescriptionBackground.rawValue)
            case .error  : Color(Self.ColorNames.errorDescriptionBackground.rawValue)
        }
    }

}
