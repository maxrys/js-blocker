
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func beginRequest(with context: NSExtensionContext) {
    }

    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
        #if DEBUG
            let domain = url?.host ?? "n/a"
            print("page(): Reload on domain = \(domain)")
        #endif
    }

    override func messageReceived(withName message: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler({ properties in
            switch message {
                case "isJSAllowedMsg",
                     "reloadPageIfUpdatedMsg":

                    let domain = properties?.url?.host
                    let fromDomain = userInfo?["fromDomain"] ?? ""

                    if domain != nil {

                        let domainHasParents = WhiteDomains.selectParents(name: domain!).isEmpty == false
                        let (state, _)       = SafariExtensionViewController.blockStateInfoGet(
                            domainName: domain!
                        )

                        page.dispatchMessageToScript(
                            withName: message,
                            userInfo: [
                                "timestamp" : Date().timeIntervalSince1970,
                                "fromDomain": fromDomain,
                                "domain"    : domain!,
                                "result"    : state.isJSAllowed || domainHasParents
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

    override func popoverWillShow(in window: SFSafariWindow) {
        // when: info.plist → SFSafariToolbarItem → Action = Popover
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // when: info.plist → SFSafariToolbarItem → Action = Command
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        window.getToolbarItem(completionHandler: { toolbarItem in
            window.getActiveTab(completionHandler: { tab in
                tab?.getActivePage(completionHandler: { page in
                    page?.getPropertiesWithCompletionHandler({ properties in
                        let domain = properties?.url?.host

                        validationHandler(
                            domain != nil, ""
                        )

                        SafariExtensionViewController.pageCurrent = page
                        SafariExtensionViewController.domainNameCurrent = domain

                        if (domain != nil) {
                            let iconPath       = Bundle.main.path(forResource: "ToolbarItemIcon"       , ofType: "pdf")!
                            let iconActivePath = Bundle.main.path(forResource: "ToolbarItemIcon-active", ofType: "pdf")!
                            let icon           = NSImage(contentsOfFile: iconPath)
                            let iconActive     = NSImage(contentsOfFile: iconActivePath)
                            let (state, _)     = SafariExtensionViewController.blockStateInfoGet(
                                domainName: domain!
                            )

                            if state.isJSAllowed
                                 {toolbarItem?.setImage(iconActive)}
                            else {toolbarItem?.setImage(icon)}
                        }

                    })
                })
            })
        })
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        // when: info.plist → SFSafariToolbarItem → Action = Popover
        return SafariExtensionViewController.shared
    }

}
