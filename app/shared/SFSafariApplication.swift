
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

extension SFSafariApplication {

    /*

    "domainNameCurrentGetWithCompletionHandler" usage:
    =====================================================================
        SFSafariApplication.domainNameCurrentGetWithCompletionHandler(
            completionHandler: { host in
                Task { // or "DispatchQueue.main.async"
                    print(host)
                }
            }
        )
    ---------------------------------------------------------------------


    "domainNameCurrentGet" usage:
    =====================================================================
        Task { // or "DispatchQueue.main.async"
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
