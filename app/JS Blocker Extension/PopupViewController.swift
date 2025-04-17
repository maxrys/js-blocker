
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

class PopupViewController: SFSafariExtensionViewController {

    static var pageCurrent: SFSafariPage?
    static var domainNameCurrent: String?
    static var popupState = PopupState()

    static let shared: PopupViewController = {
        return PopupViewController()
    }()

    static var popupShared: Popup = {
        return Popup(
            state: PopupViewController.popupState
        )
    }()

    var popupView: NSView!

    /* ###################################################################### */

    override func viewDidLoad() {
        super.viewDidLoad()

        self.popupView = NSHostingController(rootView: Self.popupShared).view
        self.view.addSubview(self.popupView)

        #if DEBUG
            print("viewDidLoad(): DB path = \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        Self.formUpdate()

        #if DEBUG
            print("viewWillAppear()")
        #endif
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.popupView.frame      = CGRect(x: 0, y: 0, width: Int(self.popupView.intrinsicContentSize.width), height: Int(self.popupView.intrinsicContentSize.height))
        self.preferredContentSize = CGSize(            width: Int(self.popupView.intrinsicContentSize.width), height: Int(self.popupView.intrinsicContentSize.height))

        #if DEBUG
            print("viewDidAppear()")
        #endif
    }

    /* ###################################################################### */

    static func messageShow(title: String, description: String, type: MessageType = .info) {
        Self.popupState.messages.removeAll()
        Self.popupState.messages.append(
            MessageInfo(
                title: title,
                description: description,
                type: type
            )
        )
    }

    static func messageHide() {
        Self.popupState.messages.removeAll()
    }

    /* ###################################################################### */

    static func formUpdate() {
        Self.popupState.reset()

        if let domainName = Self.domainNameCurrent {
            let rule          =        domainName.decodePunycode()
            let ruleForGlobal = "*." + domainName.decodePunycode().deleteWwwPrefixIfExists()
            let (state, _)    = WhiteDomains.blockingStateInfoGet(domainName: domainName)
            let domainParents = WhiteDomains.selectParents(
                name: domainName.deleteWwwPrefixIfExists()
            )

            Self.popupState.rulesForLocal  = [rule]
            Self.popupState.rulesForGlobal = [ruleForGlobal]

            /* special case for "www.domain" (rule: "*.domain") if exists rule for "domain" (rule: "domain") */
            var hasMirror: Bool? = nil
            if (domainName.hasWwwPrefix()) {
                if let noWwwDomainInfo = WhiteDomains.selectByName(domainName.deleteWwwPrefixIfExists()), noWwwDomainInfo.withSubdomains == false {
                    hasMirror = true
                }
            }

            switch state {
                case .local:
                    Self.popupState.isActiveLocalRule = true
                    Self.popupState.isActiveGlobalRule = false
                    Self.popupState.isEnabledLocalRule = false
                    Self.popupState.isEnabledGlobalRule = false
                    Self.popupState.isEnabledRuleCancel = true
                case .global:
                    Self.popupState.isActiveLocalRule = false
                    Self.popupState.isActiveGlobalRule = true
                    Self.popupState.isEnabledLocalRule = false
                    Self.popupState.isEnabledGlobalRule = false
                    Self.popupState.isEnabledRuleCancel = true
                case .none:
                    Self.popupState.isActiveLocalRule = false
                    Self.popupState.isActiveGlobalRule = false
                    Self.popupState.isEnabledLocalRule = true
                    Self.popupState.isEnabledGlobalRule = hasMirror == true ? false : true
                    Self.popupState.isEnabledRuleCancel = false
            }

            if (!domainParents.isEmpty) {
                var parents: [String] = []
                for parent in domainParents {
                    parents.append(
                        "*.\(parent.name)"
                    )
                }
                Self.messageShow(
                    title: NSLocalizedString("Inherited permissions detected from:", comment: ""),
                    description: parents.joined(separator: " | ")
                )
            }
        }
    }

    static func pageUpdate() {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: App.RULES_EXTENSION_NAME, completionHandler: { error in
            if let error = error {
                #if DEBUG
                    print("pageUpdate(): Extension reload error = \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                    print("pageUpdate(): Extension has been reloaded.")
                #endif
                if let page       = Self.pageCurrent,
                   let domainName = Self.domainNameCurrent {
                        let domainHasParents = WhiteDomains.selectParents(name: domainName).isEmpty == false
                        let (state, _) = WhiteDomains.blockingStateInfoGet(domainName: domainName)
                        page.dispatchMessageToScript(
                           withName: "reloadPageMsg",
                           userInfo: [
                               "timestamp": Date().timeIntervalSince1970,
                               "domain"   : domainName,
                               "result"   : state.isAllowed || domainHasParents
                           ]
                       )
                } else {
                    #if DEBUG
                        print("pageUpdate(): Page not found")
                    #endif
                }
            }
        })
    }

    /* ###################################################################### */

    static func onClick_buttonRuleInsert() {
        if let domainName = Self.domainNameCurrent {
            WhiteDomains.insert(
                name: domainName,
                withSubdomains: false
            )
            Self.formUpdate()
            Self.pageUpdate()
            #if DEBUG
                print("onClick_buttonRuleInsert()")
                WhiteDomains.dump()
            #endif
        }
    }

    static func onClick_buttonRuleInsertWithSubdomains() {
        if let domainName = Self.domainNameCurrent {
            WhiteDomains.insert(
                name: domainName.deleteWwwPrefixIfExists(),
                withSubdomains: true,
                skippedWww: domainName.hasWwwPrefix()
            )
            Self.formUpdate()
            Self.pageUpdate()
            #if DEBUG
                print("onClick_buttonRuleInsertWithSubdomains()")
                WhiteDomains.dump()
            #endif
        }
    }

    static func onClick_buttonRuleDelete() {
        if let domainName = Self.domainNameCurrent {
            if let domainInfo = WhiteDomains.selectByName(domainName) {
                domainInfo.delete()
                Self.formUpdate()
                Self.pageUpdate()
                #if DEBUG
                    print("onClick_buttonRuleDelete()")
                    WhiteDomains.dump()
                #endif
            } else if let domainInfo = WhiteDomains.selectByName(domainName.deleteWwwPrefixIfExists()) {
                domainInfo.delete()
                Self.formUpdate()
                Self.pageUpdate()
                #if DEBUG
                    print("onClick_buttonRuleDelete()")
                    WhiteDomains.dump()
                #endif
            }
        }
    }

}
