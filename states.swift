
import Cocoa

enum BlockingState: String {
    case domain
    case domainWithSubdomains
    case nothing

    var isAllowed: Bool {
        return self == .domain ||
               self == .domainWithSubdomains
    }
}

enum MessageState: Int {
    case info
    case ok
    case warning
    case error

    var colorTitleBackground: NSColor {
        switch self {
            case .info   : return NSColor(named: ENV.COLORNAME_MESSAGE_INFO_TITLE_BACKGROUND   ) ?? .systemPurple
            case .ok     : return NSColor(named: ENV.COLORNAME_MESSAGE_OK_TITLE_BACKGROUND     ) ?? .systemGreen
            case .warning: return NSColor(named: ENV.COLORNAME_MESSAGE_WARNING_TITLE_BACKGROUND) ?? .systemYellow
            case .error  : return NSColor(named: ENV.COLORNAME_MESSAGE_ERROR_TITLE_BACKGROUND  ) ?? .systemRed
        }
    }

    var colorDescriptionBackground: NSColor {
        switch self {
            case .info   : return NSColor(named: ENV.COLORNAME_MESSAGE_INFO_DESCRIPTION_BACKGROUND   ) ?? .systemGray
            case .ok     : return NSColor(named: ENV.COLORNAME_MESSAGE_OK_DESCRIPTION_BACKGROUND     ) ?? .systemGray
            case .warning: return NSColor(named: ENV.COLORNAME_MESSAGE_WARNING_DESCRIPTION_BACKGROUND) ?? .systemGray
            case .error  : return NSColor(named: ENV.COLORNAME_MESSAGE_ERROR_DESCRIPTION_BACKGROUND  ) ?? .systemGray
        }
    }
}
