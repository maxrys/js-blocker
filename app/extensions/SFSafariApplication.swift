
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices

extension SFSafariApplication {

    static func reloadRules() {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: EXTENSION_RULES_NAME, completionHandler: { error in
            if let error = error {
                Logger.customLog("Error reload blocking rules: \(error)")
            } else {
                let JSON = String(data: RulesHandler.JSON, encoding: .utf8) ?? NOT_APPLICABLE
                Logger.customLog("Reload blocking rules: \(JSON)")
            }
        })
    }

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

    static func domainNameCurrentGet() async -> DomainName? {
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
