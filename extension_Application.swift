
import SafariServices

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

extension SFSafariApplication {

    /*

    "domainNameCurrentGetWithCompletionHandler" usage:
    =====================================================================
        SFSafariApplication.domainNameCurrentGetWithCompletionHandler(
            completionHandler: { host in
                Task {
                    print(host)
                }
            }
        )
    ---------------------------------------------------------------------


    "domainNameCurrentGet" usage:
    =====================================================================
        Task {
            if let host = await SFSafariApplication.domainNameCurrentGet() {
                print(host)
            }
        }
    ---------------------------------------------------------------------

    */

    static func domainNameCurrentGetWithCompletionHandler(completionHandler: @escaping (String?) -> Void) {
        SFSafariApplication.getActiveWindow(completionHandler: { window in
            window?.getActiveTab(completionHandler: { tab in
                tab?.getActivePage(completionHandler: { page in
                    page?.getPropertiesWithCompletionHandler({ properties in
                        completionHandler(
                            properties?.url?.host
                        )
                    })
                })
            })
        })
    }

    static func domainNameCurrentGet() async -> String? {
        let windows = await SFSafariApplication.activeWindow()
        let tab = await windows?.activeTab()
        let page = await tab?.activePage()
        let properties = await page?.properties()
        let url = properties?.url
        let host = url?.host
        return host
    }

    static func pageCurrentReload() async {
        let windows = await SFSafariApplication.activeWindow()
        let tab = await windows?.activeTab()
        let page = await tab?.activePage()
        page?.reload()
    }

    static func pageCurrentGet() async -> SFSafariPage? {
        let windows = await SFSafariApplication.activeWindow()
        let tab = await windows?.activeTab()
        let page = await tab?.activePage()
        return page
    }

}
