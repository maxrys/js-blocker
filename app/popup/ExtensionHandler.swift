
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices

class ExtensionHandler: SFSafariExtensionHandler {

    static let ICON_NONE     = NSImage(contentsOfFile: Bundle.main.path(forResource: "toolbarIcon-none"    , ofType: "pdf")!)
    static let ICON_NO_ONE   = NSImage(contentsOfFile: Bundle.main.path(forResource: "toolbarIcon-no-one"  , ofType: "pdf")!)
    static let ICON_EXACT    = NSImage(contentsOfFile: Bundle.main.path(forResource: "toolbarIcon-exact"   , ofType: "pdf")!)
    static let ICON_WILDCARD = NSImage(contentsOfFile: Bundle.main.path(forResource: "toolbarIcon-wildcard", ofType: "pdf")!)

    override func beginRequest(with context: NSExtensionContext) {
    }

    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
        Logger.customLog("page(): Reload on domain = \(url?.host ?? "n/a")")
    }

    override func messageReceived(withName message: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler({ properties in
            if (message == "onChangeMatch") {
                if let userInfo, let forDomain = userInfo["forDomain"] as? DomainName, let _ = properties?.url?.host {
                    Logger.customLog("messageReceived(): Message = \(message)")
                    page.dispatchMessageToScript(
                        withName: message,
                        userInfo: [
                            "domain": forDomain,
                            "match" : ADModel.matchType(
                                name: forDomain
                            ).toStrictJS
                        ]
                    )
                }
            }
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

                        if let page       = page,
                           let domainName = domainName {
                            Task { @MainActor in
                                PopupState.shared.setPageAndDomain(page, domainName)
                                switch PopupState.shared.match {
                                    case .none    : toolbarItem?.setImage(Self.ICON_NONE)
                                    case .noOne   : toolbarItem?.setImage(Self.ICON_NO_ONE)
                                    case .exact   : toolbarItem?.setImage(Self.ICON_EXACT)
                                    case .wildcard: toolbarItem?.setImage(Self.ICON_WILDCARD)
                                }
                            }
                        } else {
                            Task { @MainActor in
                                PopupState.shared.reset()
                            }
                        }

                    })
                })
            })
        })
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        /* when: info.plist → SFSafariToolbarItem → Action = Popover */
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        /* when: info.plist → SFSafariToolbarItem → Action = Popover */
        ViewController.shared
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        /* when: info.plist → SFSafariToolbarItem → Action = Command */
    }

}
