
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

class ViewController: SFSafariExtensionViewController {

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
        PopupState.shared.refresh()
    }

    /* ###################################################################### */

    func onClick_ruleExactInsert(lifetime: TimeInterval? = nil) {
        if let domainName = PopupState.shared.domainName {

            var success: [String] = []
            var failure: [String] = []

            if case .success = AllowedDomains.insert(name: domainName, type: MATCH_TYPE_STRING_EXACT, expiresAt: lifetime.ifNil(defaultValue: 0) { value in Int64(Date.now + value) } )
                 { success.append(domainName.decodePunycode()) }
            else { failure.append(domainName.decodePunycode()) }

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
                Task { @MainActor in
                    SFSafariApplication.reloadRules()
                    PopupState.shared.refresh()
                    PopupState.shared.jsSetMatch()
                }
            }

            Logger.customLog("onClick_ruleExactInsert()")
            AllowedDomains.dump()
        }
    }

    func onClick_ruleWildcardInsert(selected: Set<Int>, lifetime: TimeInterval? = nil) {
        if let domainName = PopupState.shared.domainName {
            if (selected.isEmpty) {

                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("At least 1 subdomain must be selected!", comment: "")
                )

            } else {

                let domains = [domainName] + domainName.topDomains(isDeleteTLD: true)
                var success: [String] = []
                var failure: [String] = []

                for (index, name) in domains.enumerated() {
                    if (selected.contains(index)) {
                        if case .success = AllowedDomains.insert(name: name, type: MATCH_TYPE_STRING_WILDCARD, expiresAt: lifetime.ifNil(defaultValue: 0) { value in Int64(Date.now + value) } )
                             { success.append(name.decodePunycode()) }
                        else { failure.append(name.decodePunycode()) }
                    }
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
                    Task { @MainActor in
                        SFSafariApplication.reloadRules()
                        PopupState.shared.refresh()
                        PopupState.shared.jsSetMatch()
                    }
                }
            }

            Logger.customLog("onClick_ruleWildcardInsert()")
            AllowedDomains.dump()
        }
    }

    func onClick_ruleDelete() {
        if let domainName = PopupState.shared.domainName, let match = PopupState.shared.match {

            var success: [String] = []
            var failure: [String] = []

            if (match.isExact) {

                if let domain = AllowedDomains.select(domainName) {
                    let name = domain.name
                    switch AllowedDomains.delete([name]) {
                        case .success: success.append(name.decodePunycode())
                        case .failure: failure.append(name.decodePunycode())
                    }
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

            if (match.isWildcard) {

                AllowedDomains.selectWildcardDomains(domainName).forEach { domain in
                    let name = domain.name
                    switch AllowedDomains.delete([name]) {
                        case .success: success.append(name.decodePunycode())
                        case .failure: failure.append(name.decodePunycode())
                    }
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
                Task { @MainActor in
                    SFSafariApplication.reloadRules()
                    PopupState.shared.refresh()
                    PopupState.shared.jsSetMatch()
                }
            }

            Logger.customLog("onClick_ruleDelete()")
            AllowedDomains.dump()
        }
    }

}
