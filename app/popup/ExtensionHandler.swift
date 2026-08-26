
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices

class ExtensionHandler: SFSafariExtensionHandler {

    static let ICON_NONE     = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconToolbar-none"    , ofType: "pdf")!)
    static let ICON_NO_ONE   = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconToolbar-no-one"  , ofType: "pdf")!)
    static let ICON_EXACT    = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconToolbar-exact"   , ofType: "pdf")!)
    static let ICON_WILDCARD = NSImage(contentsOfFile: Bundle.main.path(forResource: "iconToolbar-wildcard", ofType: "pdf")!)

    override func beginRequest(with context: NSExtensionContext) {
    }

    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
        Logger.customLog("page(): Reload on domain = \(url?.host ?? "n/a")")
    }

    override func messageReceived(withName message: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler({ properties in
            if let realDomainName = properties?.url?.host {
                if let frameDomainName = userInfo?["domainName"] as? DomainName {
                    if let userInfo {
                        if let logData = try? JSONSerialization.data(withJSONObject: userInfo) {
                            if let logString = String(data: logData, encoding: .utf8) {
                                Logger.customLog("\(message) from \(realDomainName)|\(frameDomainName): \(logString)")
                            }
                        }
                    }
                    switch message {
                        case "js:getMatch.request":
                            page.dispatchMessageToScript(
                                withName: "js:getMatch.response",
                                userInfo: [
                                    "match": ADModel.matchType(
                                        name: realDomainName
                                    ).toStrictJS
                                ]
                            )
                        case "js:setScripts.request",
                             "js:getScripts.response":
                            if let scripts = userInfo?["scripts"] as? String {
                                Task { @MainActor in
                                    PopupState.shared.scripts[
                                        realDomainName, default: [:]
                                    ][frameDomainName] = scripts.split(
                                        separator: "\n",
                                        omittingEmptySubsequences: true
                                    ).map(String.init)
                                }
                            }
                        default: break
                    }
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
                                PopupState.shared.onSetPageAndDomain(page, domainName)
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
