
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

class PopupViewController: SFSafariExtensionViewController {

    static var pageCurrent: SFSafariPage?
    static var domainNameCurrent: String?
    static var popupStateModel = PopupStateModel(
        ruleForDomain: nil,
        ruleForParent: nil,
        ruleForDomain_isActive: false,
        ruleForParent_isActive: false,
        ruleForDomain_isEnabled: false,
        ruleForParent_isEnabled: false,
        ruleCancel_isEnabled: false,
        messages: []
    )

    static let shared: PopupViewController = {
        return PopupViewController()
    }()

    static var popupShared: Popup = {
        return Popup(stateModel: popupStateModel)
    }()

    var popupHost: NSHostingController<Popup>? = nil
    var popupView: NSView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.popupHost = NSHostingController(rootView: PopupViewController.popupShared)
        self.popupView = self.popupHost!.view
        self.view.addSubview(self.popupView!)

        #if DEBUG
            print("viewDidLoad(): DB path = \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        PopupViewController.formUpdate()

        #if DEBUG
            print("viewWillAppear()")
        #endif
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.popupView!.frame     = CGRect(x: 0, y: 0, width: Int(self.popupView!.intrinsicContentSize.width), height: Int(self.popupView!.intrinsicContentSize.height))
        self.preferredContentSize = CGSize(            width: Int(self.popupView!.intrinsicContentSize.width), height: Int(self.popupView!.intrinsicContentSize.height))

        #if DEBUG
            print("viewDidAppear()")
        #endif
    }

    static func messageShow(title: String, description: String, type: Message.MessageType = .info) {
        popupStateModel.messages.removeAll()
        popupStateModel.messages.append(
            MessageInfo(
                title: title,
                description: description,
                type: type
            )
        )
    }

    static func messageHide() {
        popupStateModel.messages.removeAll()
    }

    // ######################################################################

    static func formUpdate() {
        popupStateModel.ruleForDomain = nil
        popupStateModel.ruleForParent = nil
        popupStateModel.ruleForDomain_isActive = false
        popupStateModel.ruleForParent_isActive = false
        popupStateModel.ruleForDomain_isEnabled = false
        popupStateModel.ruleForParent_isEnabled = false
        popupStateModel.ruleCancel_isEnabled = false
        messageHide()

        if let domainName = domainNameCurrent {
            let rule                =        domainName.decodePunycode()
            let ruleForParentDomain = "*." + domainName.decodePunycode().deleteWwwPrefixIfExists()
            let (state, _)          = WhiteDomains.blockingStateInfoGet(domainName: domainName)

            popupStateModel.ruleForDomain = rule
            popupStateModel.ruleForParent = ruleForParentDomain

            // special case for "www.domain" (rule: "*.domain") if exists rule for "domain" (rule: "domain")
            var hasMirror: Bool? = nil
            if domainName.hasWwwPrefix() {
                if let noWwwDomainInfo = WhiteDomains.selectByName(name: domainName.deleteWwwPrefixIfExists()), noWwwDomainInfo.withSubdomains == false {
                    hasMirror = true
                }
            }

            switch state {
                case .domain:
                    popupStateModel.ruleForDomain_isActive = true
                    popupStateModel.ruleForParent_isActive = false
                    popupStateModel.ruleForDomain_isEnabled = false
                    popupStateModel.ruleForParent_isEnabled = false
                    popupStateModel.ruleCancel_isEnabled = true
                case .domainWithSubdomains:
                    popupStateModel.ruleForDomain_isActive = false
                    popupStateModel.ruleForParent_isActive = true
                    popupStateModel.ruleForDomain_isEnabled = false
                    popupStateModel.ruleForParent_isEnabled = false
                    popupStateModel.ruleCancel_isEnabled = true
                case .nothing:
                    popupStateModel.ruleForDomain_isActive = false
                    popupStateModel.ruleForParent_isActive = false
                    popupStateModel.ruleForDomain_isEnabled = true
                    popupStateModel.ruleForParent_isEnabled = hasMirror == true ? false : true
                    popupStateModel.ruleCancel_isEnabled = false
            }

            let domainParents = WhiteDomains.selectParents(
                name: domainName.deleteWwwPrefixIfExists()
            )

            if !domainParents.isEmpty {
                var parents: [String] = []
                for parent in domainParents {
                    parents.append(
                        "*.\(parent.name)"
                    )
                }
                messageShow(
                    title: NSLocalizedString("Inherited permissions detected from:", comment: ""),
                    description: parents.joined(separator: " | ")
                )
            }
        }
    }

    static func pageUpdate() {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: ENV.APP_RULES_EXTENSION_NAME, completionHandler: { error in
            if let error = error {
                #if DEBUG
                    print("pageUpdate(): Extension reload error = \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                    print("pageUpdate(): Extension has been reloaded.")
                #endif
                if let page       = pageCurrent,
                   let domainName = domainNameCurrent {
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

    // ######################################################################

    static func onClick_buttonRuleInsert() {
        if let domainName = domainNameCurrent {
            WhiteDomains.insert(
                name: domainName,
                withSubdomains: false
            )
            formUpdate()
            pageUpdate()
            #if DEBUG
                print("onClick_buttonRuleInsert()")
                WhiteDomains.dump()
            #endif
        }
    }

    static func onClick_buttonRuleInsertWithSubdomains() {
        if let domainName = domainNameCurrent {
            WhiteDomains.insert(
                name: domainName.deleteWwwPrefixIfExists(),
                withSubdomains: true,
                skippedWww: domainName.hasWwwPrefix()
            )
            formUpdate()
            pageUpdate()
            #if DEBUG
                print("onClick_buttonRuleInsertWithSubdomains()")
                WhiteDomains.dump()
            #endif
        }
    }

    static func onClick_buttonRuleDelete() {
        if let domainName = domainNameCurrent {
            if let domainInfo = WhiteDomains.selectByName(name: domainName) {
                domainInfo.delete()
                formUpdate()
                pageUpdate()
                #if DEBUG
                    print("onClick_buttonRuleDelete()")
                    WhiteDomains.dump()
                #endif
            } else if let domainInfo = WhiteDomains.selectByName(name: domainName.deleteWwwPrefixIfExists()) {
                domainInfo.delete()
                formUpdate()
                pageUpdate()
                #if DEBUG
                    print("onClick_buttonRuleDelete()")
                    WhiteDomains.dump()
                #endif
            }
        }
    }

}
