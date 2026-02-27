
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices

class ExtensionHandler: SFSafariExtensionHandler {

    static let ICON_LOCAL  = NSImage(contentsOfFile: Bundle.main.path(forResource: "ToolbarIcon-local" , ofType: "pdf")!)
    static let ICON_GLOBAL = NSImage(contentsOfFile: Bundle.main.path(forResource: "ToolbarIcon-global", ofType: "pdf")!)
    static let ICON_NONE   = NSImage(contentsOfFile: Bundle.main.path(forResource: "ToolbarIcon-none"  , ofType: "pdf")!)

    override func beginRequest(with context: NSExtensionContext) {
    }

    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
        let domainName = url?.host ?? "n/a"
        Logger.customLog("page(): Reload on domain = \(domainName)")
    }

    override func messageReceived(withName message: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler({ properties in
            switch message {
                case "isJSAllowedMsg", "reloadPageIfUpdatedMsg":

                    let domainName = properties?.url?.host
                    let fromDomain = userInfo?["fromDomain"] ?? ""

                    if (domainName != nil) {
                        let state = WhiteDomains.blockingState(name: domainName!)
                        page.dispatchMessageToScript(
                            withName: message,
                            userInfo: [
                                "timestamp" : Date().timeIntervalSince1970,
                                "fromDomain": fromDomain,
                                "domain"    : domainName!,
                                "result"    : state.isAllowed
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

            Logger.customLog("messageReceived(): Message = \(message)")
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

                        if let page,
                           let domainName {
                            ExtensionController.page = page
                            ExtensionController.domainName = domainName
                            ExtensionController.blockingState = WhiteDomains.blockingState(name: domainName)
                            switch ExtensionController.blockingState {
                                case .local : toolbarItem?.setImage(Self.ICON_LOCAL)
                                case .global: toolbarItem?.setImage(Self.ICON_GLOBAL)
                                case .none  : toolbarItem?.setImage(Self.ICON_NONE)
                            }
                        } else {
                            ExtensionController.page = nil
                            ExtensionController.domainName = nil
                            ExtensionController.blockingState = .none
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
        return ExtensionController.shared
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        /* when: info.plist → SFSafariToolbarItem → Action = Command */
    }

}
