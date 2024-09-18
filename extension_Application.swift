
import SafariServices

class ENV {
    static let APP_GROUP_NAME           = "97CZR6J379.maxrys.js-blocker"
    static let APP_NAME                 = "maxrys.js-blocker"
    static let APP_POPUP_EXTENSION_NAME = "maxrys.js-blocker.extension"
    static let APP_RULES_EXTENSION_NAME = "maxrys.js-blocker.rules"
    static let APP_DB_LOCAL_NAME        = "JSBlocker.sqlite"
}

enum MessageState: Int {
    case info    =  1
    case ok      =  2
    case warning = -1
    case error   = -2

    var titleBackgroundColor: NSColor {
        switch self {
            case .info   : return NSColor(named: "Message Title Background Color Info"   ) ?? .systemPurple
            case .ok     : return NSColor(named: "Message Title Background Color Ok"     ) ?? .systemGreen
            case .warning: return NSColor(named: "Message Title Background Color Warning") ?? .systemYellow
            case .error  : return NSColor(named: "Message Title Background Color Error"  ) ?? .systemRed
        }
    }

    var backgroundColor: NSColor {
        switch self {
            case .info   : return NSColor(named: "Message Background Color Info"   ) ?? .systemGray
            case .ok     : return NSColor(named: "Message Background Color Ok"     ) ?? .systemGray
            case .warning: return NSColor(named: "Message Background Color Warning") ?? .systemGray
            case .error  : return NSColor(named: "Message Background Color Error"  ) ?? .systemGray
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
