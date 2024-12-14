
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func beginRequest(with context: NSExtensionContext) {
    }

    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
        #if DEBUG
            let domainName = url?.host ?? "n/a"
            print("page(): Reload on domain = \(domainName)")
        #endif
    }

    override func messageReceived(withName message: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler({ properties in
            switch message {
                case "isJSAllowedMsg",
                     "reloadPageIfUpdatedMsg":

                    let domainName = properties?.url?.host
                    let fromDomain = userInfo?["fromDomain"] ?? ""

                    if domainName != nil {

                        let domainHasParents = WhiteDomains.selectParents(name: domainName!).isEmpty == false
                        let (state, _)       = WhiteDomains.blockingStateInfoGet(
                            domainName: domainName!
                        )

                        page.dispatchMessageToScript(
                            withName: message,
                            userInfo: [
                                "timestamp" : Date().timeIntervalSince1970,
                                "fromDomain": fromDomain,
                                "domain"    : domainName!,
                                "result"    : state.isAllowed || domainHasParents
                            ]
                        )

                    } else {
                        page.dispatchMessageToScript(
                            withName: message,
                            userInfo: [
                                "timestamp" : Date().timeIntervalSince1970,
                                "fromDomain": "",
                                "domain"    : "",
                                "result"    : ""
                            ]
                        )
                    }

                default:
                    page.dispatchMessageToScript(
                        withName: message,
                        userInfo: [
                            "timestamp": Date().timeIntervalSince1970,
                            "result"   : "unknown request"
                        ]
                    )
            }

            #if DEBUG
                print("messageReceived(): Message = \(message)")
            #endif
        })
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        window.getToolbarItem(completionHandler: { toolbarItem in
            window.getActiveTab(completionHandler: { tab in
                tab?.getActivePage(completionHandler: { page in
                    page?.getPropertiesWithCompletionHandler({ properties in
                        let domainName = properties?.url?.host

                        validationHandler(
                            domainName != nil, ""
                        )

                        SafariExtensionViewController.pageCurrent       = page
                        SafariExtensionViewController.domainNameCurrent = domainName

                        if (domainName != nil) {
                            let iconPath       = Bundle.main.path(forResource: "ToolbarItemIcon"       , ofType: "pdf")!
                            let iconActivePath = Bundle.main.path(forResource: "ToolbarItemIcon-active", ofType: "pdf")!
                            let icon           = NSImage(contentsOfFile: iconPath)
                            let iconActive     = NSImage(contentsOfFile: iconActivePath)
                            let (state, _)     = WhiteDomains.blockingStateInfoGet(
                                domainName: domainName!
                            )

                            if state.isAllowed
                                 {toolbarItem?.setImage(iconActive)}
                            else {toolbarItem?.setImage(icon)}
                        }

                    })
                })
            })
        })
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        // when: info.plist → SFSafariToolbarItem → Action = Popover
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        // when: info.plist → SFSafariToolbarItem → Action = Popover
        return SafariExtensionViewController.shared
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // when: info.plist → SFSafariToolbarItem → Action = Command
    }

}
