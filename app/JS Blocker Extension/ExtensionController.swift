
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

class ExtensionController: SFSafariExtensionViewController {

    static var page: SFSafariPage?
    static var domainName: String?
    static var blockingState: BlockingType = .none
    static var popupState = PopupState()

    static let shared: ExtensionController = {
        return ExtensionController()
    }()

    static var popupShared: Popup = {
        Popup(
            state: ExtensionController.popupState
        )
    }()

    var popupView: NSView!

    /* ###################################################################### */

    override func viewDidLoad() {
        super.viewDidLoad()
        self.popupView = NSHostingController(rootView: Self.popupShared).view
        self.popupView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.popupView)
        NSLayoutConstraint.activate([
            self.popupView.leadingAnchor .constraint(equalTo: self.view.leadingAnchor),
            self.popupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.popupView.topAnchor     .constraint(equalTo: self.view.topAnchor),
            self.popupView.bottomAnchor  .constraint(equalTo: self.view.bottomAnchor),
        ])
        WhiteDomains.dump()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.formUpdate()
    }

    /* ###################################################################### */

    func formUpdate() {
        Self.popupState.reset()

        if let domainName = Self.domainName {

            Self.blockingState = WhiteDomains.blockingState(
                name: domainName
            )

            /* MARK: local rule */
            Self.popupState.indecesForLocal = [0]
            Self.popupState.rulesForLocal = [
                domainName.decodePunycode()
            ]

            /* MARK: global rules */
            Self.popupState.indecesForGLobal = []
            Self.popupState.rulesForGlobal = []

            let domainsInDB: [String] = WhiteDomains.selectGlobalDomains(domainName).map {
                domainInfo in domainInfo.name
            }

            var domains: [String] = [domainName] + domainName.topDomains()
            domains.removeLast() /* delete TLD (top-level domain), eg ".com", ".net" … */

            for (index, domain) in domains.enumerated() {
                if (domainsInDB.contains(domain)) {
                    Self.popupState.indecesForGLobal.append(
                        index
                    )
                }
                Self.popupState.rulesForGlobal.append(
                    "*." + domain.decodePunycode()
                )
            }

            if (domains.count == 1) {
                Self.popupState.indecesForGLobal = [0]
            }

            /* MARK: states of popup elements */
            switch Self.blockingState {
                case .local:
                    Self.popupState.isActiveLocalRule   = true
                    Self.popupState.isActiveGlobalRule  = false
                    Self.popupState.isEnabledLocalRule  = false
                    Self.popupState.isEnabledGlobalRule = false
                    Self.popupState.isEnabledRuleCancel = true
                case .global:
                    Self.popupState.isActiveLocalRule   = false
                    Self.popupState.isActiveGlobalRule  = true
                    Self.popupState.isEnabledLocalRule  = false
                    Self.popupState.isEnabledGlobalRule = false
                    Self.popupState.isEnabledRuleCancel = true
                case .none:
                    Self.popupState.isActiveLocalRule   = false
                    Self.popupState.isActiveGlobalRule  = false
                    Self.popupState.isEnabledLocalRule  = true
                    Self.popupState.isEnabledGlobalRule = true
                    Self.popupState.isEnabledRuleCancel = false
            }
        }
    }

    func pageUpdate() {
        if let page       = Self.page,
           let domainName = Self.domainName {
               page.dispatchMessageToScript(
                   withName: "reloadPageMsg",
                   userInfo: [
                       "timestamp": Date().timeIntervalSince1970,
                       "domain"   : domainName,
                       "result"   : Self.blockingState.isAllowed
                   ]
               )
        } else {
            Logger.customLog("pageUpdate(): Page not found")
        }
    }

    /* ###################################################################### */

    func onClick_buttonRuleLocalInsert() {
        if let domainName = Self.domainName {
            var success: [String] = []
            var failure: [String] = []

            if (WhiteDomains.insert(name: domainName, isGlobal: false))
                 { success.append(domainName) }
            else { failure.append(domainName) }

            /* message */
            if (success.count > 0) {
                MessageBox.insert(
                    type: .ok,
                    title: NSLocalizedString("Permission for the following domain was added:", comment: ""),
                    description: success.joined(separator: "\n")
                )
            }
            if (failure.count > 0) {
                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("Permission for the following domain was not added:", comment: ""),
                    description: failure.joined(separator: "\n")
                )
            }

            /* ui update */
            if (success.count > 0) {
                self.formUpdate()
                self.pageUpdate()
            }

            Logger.customLog("onClick_buttonRuleLocalInsert()")
            WhiteDomains.dump()
        }
    }

    func onClick_buttonRuleGlobalInsert(indeces: [Int]) {
        if let domainName = Self.domainName {
            if (indeces.isEmpty) {

                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("At least 1 subdomain must be selected!", comment: "")
                )

            } else {

                let domains = [domainName] + domainName.topDomains()
                var success: [String] = []
                var failure: [String] = []

                for index in indeces where index < domains.count {
                    if (WhiteDomains.insert(name: domains[index], isGlobal: true))
                         { success.append(domains[index]) }
                    else { failure.append(domains[index]) }
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(
                        type: .ok,
                        title: NSLocalizedString("Global permissions for the following domains were added:", comment: ""),
                        description: success.joined(separator: "\n")
                    )
                }
                if (failure.count > 0) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Global permissions for the following domains were not added:", comment: ""),
                        description: failure.joined(separator: "\n")
                    )
                }

                /* ui update */
                if (success.count > 0) {
                    self.formUpdate()
                    self.pageUpdate()
                }
            }

            Logger.customLog("onClick_buttonRuleGlobalInsert()")
            WhiteDomains.dump()
        }
    }

    func onClick_buttonRuleDelete() {
        if let domainName = Self.domainName {
            var success: [String] = []
            var failure: [String] = []

            if (Self.blockingState == .local) {

                if let topDomain = WhiteDomains.selectByName(domainName) {
                    let name = topDomain.name
                    if (topDomain.delete()) { success.append(name) }
                    else                    { failure.append(name) }
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(
                        type: .ok,
                        title: NSLocalizedString("Permission for the following domain was removed:", comment: ""),
                        description: success.joined(separator: "\n")
                    )
                }
                if (failure.count > 0) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Permission for the following domain was not removed:", comment: ""),
                        description: failure.joined(separator: "\n")
                    )
                }
            }

            if (Self.blockingState == .global) {

                WhiteDomains.selectGlobalDomains(domainName).forEach { topDomain in
                    let name = topDomain.name
                    if (topDomain.delete()) { success.append(name) }
                    else                    { failure.append(name) }
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(
                        type: .ok,
                        title: NSLocalizedString("Global permissions for the following domains were removed:", comment: ""),
                        description: success.joined(separator: "\n")
                    )
                }
                if (failure.count > 0) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Global permissions for the following domains were not removed:", comment: ""),
                        description: failure.joined(separator: "\n")
                    )
                }
            }

            /* ui update */
            if (success.count > 0) {
                self.formUpdate()
                self.pageUpdate()
            }

            Logger.customLog("onClick_buttonRuleDelete()")
            WhiteDomains.dump()
        }
    }

}
