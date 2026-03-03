
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

class ViewController: SFSafariExtensionViewController {

    static var page: SFSafariPage?
    static var domainName: String?
    static var matchType: MatchType = .none
    static let shared = ViewController()

    /* ###################################################################### */

    override func viewDidLoad() {
        super.viewDidLoad()

        let popupView = NSHostingController(rootView: Popup()).view
        self.view.addSubview(popupView)

        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.leadingAnchor .constraint(equalTo: self.view.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            popupView.topAnchor     .constraint(equalTo: self.view.topAnchor),
            popupView.bottomAnchor  .constraint(equalTo: self.view.bottomAnchor),
        ])
        AllowedDomains.dump()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.popupStateUpdate()
    }

    /* ###################################################################### */

    func popupStateUpdate() {
        if let domainName = Self.domainName {

            Self.matchType = AllowedDomains.matchType(
                name: domainName
            )

            let domainsFromStorage: [String] = AllowedDomains.selectWildcardDomains(domainName).map {
                domainInfo in domainInfo.name
            }

            var wildcardRules: [String] = []
            var wildcardIndices: [Int] = []

            var domains: [String] = [domainName] + domainName.topDomains()
            domains.removeLast() /* delete TLD (top-level domain), eg ".com", ".net" … */

            for (index, domain) in domains.enumerated() {
                if (domainsFromStorage.contains(domain)) {
                    wildcardIndices.append(
                        index
                    )
                }
                wildcardRules.append(
                    "*." + domain.decodePunycode()
                )
            }

            if (domains.count == 1) {
                wildcardIndices = [0]
            }

            PopupState.shared.exactRule = domainName.decodePunycode()
            PopupState.shared.wildcardRules = wildcardRules
            switch Self.matchType {
                case .exact   : PopupState.shared.match = .exact
                case .wildcard: PopupState.shared.match = .wildcard(indices: wildcardIndices)
                case .none    : PopupState.shared.match = .none
            }

        } else {
            PopupState.shared.match = .noDomain
            PopupState.shared.exactRule = ""
            PopupState.shared.wildcardRules = []
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
                       "result"   : Self.matchType.isAllowedJS
                   ]
               )
        } else {
            Logger.customLog("pageUpdate(): Page not found")
        }
    }

    /* ###################################################################### */

    func onClick_ruleExactInsert() {
        if let domainName = Self.domainName {
            var success: [String] = []
            var failure: [String] = []

            if (AllowedDomains.insert(name: domainName, isWildcard: false))
                 { success.append(domainName) }
            else { failure.append(domainName) }

            /* message */
            if (success.count > 0) {
                MessageBox.insert(
                    type: .ok,
                    title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                    description: success.joined(separator: "\n")
                )
            }
            if (failure.count > 0) {
                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("Exact rule for the following domain was not added:", comment: ""),
                    description: failure.joined(separator: "\n")
                )
            }

            /* ui update */
            if (success.count > 0) {
                self.popupStateUpdate()
                self.pageUpdate()
            }

            Logger.customLog("onClick_ruleExactInsert()")
            AllowedDomains.dump()
        }
    }

    func onClick_ruleWildcardInsert(indices: [Int]) {
        if let domainName = Self.domainName {
            if (indices.isEmpty) {

                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("At least 1 subdomain must be selected!", comment: "")
                )

            } else {

                let domains = [domainName] + domainName.topDomains()
                var success: [String] = []
                var failure: [String] = []

                for index in indices where index < domains.count {
                    if (AllowedDomains.insert(name: domains[index], isWildcard: true))
                         { success.append(domains[index]) }
                    else { failure.append(domains[index]) }
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(
                        type: .ok,
                        title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                        description: success.joined(separator: "\n")
                    )
                }
                if (failure.count > 0) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Wildcard rules for the following domains were not added:", comment: ""),
                        description: failure.joined(separator: "\n")
                    )
                }

                /* ui update */
                if (success.count > 0) {
                    self.popupStateUpdate()
                    self.pageUpdate()
                }
            }

            Logger.customLog("onClick_ruleWildcardInsert()")
            AllowedDomains.dump()
        }
    }

    func onClick_ruleDelete() {
        if let domainName = Self.domainName {
            var success: [String] = []
            var failure: [String] = []

            if (Self.matchType == .exact) {

                if let domain = AllowedDomains.select(domainName) {
                    let name = domain.name
                    if (AllowedDomains.delete([name])) { success.append(name) }
                    else                               { failure.append(name) }
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(
                        type: .ok,
                        title: NSLocalizedString("Exact rule for the following domain was removed:", comment: ""),
                        description: success.joined(separator: "\n")
                    )
                }
                if (failure.count > 0) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Exact rule for the following domain was not removed:", comment: ""),
                        description: failure.joined(separator: "\n")
                    )
                }
            }

            if (Self.matchType == .wildcard) {

                AllowedDomains.selectWildcardDomains(domainName).forEach { domain in
                    let name = domain.name
                    if (AllowedDomains.delete([name])) { success.append(name) }
                    else                               { failure.append(name) }
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(
                        type: .ok,
                        title: NSLocalizedString("Wildcard rules for the following domains were removed:", comment: ""),
                        description: success.joined(separator: "\n")
                    )
                }
                if (failure.count > 0) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Wildcard rules for the following domains were not removed:", comment: ""),
                        description: failure.joined(separator: "\n")
                    )
                }
            }

            /* ui update */
            if (success.count > 0) {
                self.popupStateUpdate()
                self.pageUpdate()
            }

            Logger.customLog("onClick_ruleDelete()")
            AllowedDomains.dump()
        }
    }

}
