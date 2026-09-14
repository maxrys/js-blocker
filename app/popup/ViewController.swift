
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

class ViewController: SFSafariExtensionViewController {

    static let shared = ViewController()

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

    /* ###################################################################### */

    func onClick_ruleExactInsert() {
        if let domainName = PopupState.shared.domainName, let match = PopupState.shared.match {

            let type: String? = {
                switch match {
                    case .noOne      : MATCH_TYPE_STRING_EXACT
                    case .noOneScript: MATCH_TYPE_STRING_EXACT_SCRIPT
                    default          : nil
                }
            }()

            guard let type else {
                return
            }

            var success: [String] = []
            var failure: [String] = []

            switch AllowedDomains.insert(name: domainName, type: type, expiresAt: PopupState.shared.lifetime.ifNil(defaultValue: 0) { value in Int64(Date.now + value) } ) {
                case .failure: failure.append(domainName.decodePunycode())
                case .success: success.append(domainName.decodePunycode())
                    if (match.isNoOneScript) {
                        ScriptsCart.saveIsOnToStorage(for: domainName)
                        ScriptsCart.resetIsOn()
                    }
            }

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
                    PopupState.shared.onChangeMatch()
                }
            }

            Logger.customLog("onClick_ruleExactInsert()")
            AllowedDomains.dump()
        }
    }

    func onClick_ruleWildcardInsert(selected: Set<Int>) {
        if let domainName = PopupState.shared.domainName, let match = PopupState.shared.match {
            if (selected.isEmpty) {

                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("At least 1 subdomain must be selected!", comment: "")
                )

            } else {

                let type: String? = {
                    switch match {
                        case .noOne      : MATCH_TYPE_STRING_WILDCARD
                        case .noOneScript: MATCH_TYPE_STRING_WILDCARD_SCRIPT
                        default          : nil
                    }
                }()

                guard let type else {
                    return
                }

                let domains = [domainName] + domainName.topDomains(isDeleteTLD: true)
                var success: [String] = []
                var failure: [String] = []

                for (index, name) in domains.enumerated() {
                    if (selected.contains(index)) {
                        switch AllowedDomains.insert(name: name, type: type, expiresAt: PopupState.shared.lifetime.ifNil(defaultValue: 0) { value in Int64(Date.now + value) } ) {
                            case .failure: failure.append(name.decodePunycode())
                            case .success: success.append(name.decodePunycode())
                                if (match.isNoOneScript) {
                                    ScriptsCart.saveIsOnToStorage(for: name)
                                }
                        }
                    }
                }
                ScriptsCart.resetIsOn()

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
                        PopupState.shared.onChangeMatch()
                    }
                }
            }

            Logger.customLog("onClick_ruleWildcardInsert()")
            AllowedDomains.dump()
        }
    }

    func onClick_ruleDelete() {
        if let domainName = PopupState.shared.domainName {
            if let match = PopupState.shared.match {

                if (match.isExact || match.isExactScript) {

                    let name = domainName

                    switch AllowedDomains.delete([name]) {
                        case .success:
                            MessageBox.insert(
                                type: .ok,
                                title: NSLocalizedString("Exact rule for the following domain was removed:", comment: ""),
                                description: name.decodePunycode()
                            )
                            if (match.isExactScript) {
                                if case .success = AllowedScripts.delete(domain: name) {
                                    ScriptsManager.reset    (for: name)
                                    ScriptsManager.resetIsOn(for: name)
                                }
                            }
                            Task { @MainActor in
                                PopupState.shared.onChangeMatch()
                            }
                        case .failure:
                            MessageBox.insert(
                                type: .error,
                                title: NSLocalizedString("Exact rule for the following domain was not removed:", comment: ""),
                                description: name.decodePunycode()
                            )
                    }

                }

                if (match.isWildcard || match.isWildcardScript) {

                    let name = AllowedDomains.selectDomainAndTopDomains(domainName, types: [
                        MATCH_TYPE_STRING_WILDCARD,
                        MATCH_TYPE_STRING_WILDCARD_SCRIPT
                    ]).first?.name ?? domainName

                    switch AllowedDomains.delete([name]) {
                        case .success:
                            MessageBox.insert(
                                type: .ok,
                                title: NSLocalizedString("Wildcard rule for the following domain was removed:", comment: ""),
                                description: name.decodePunycode()
                            )
                            if (match.isWildcardScript) {
                                if case .success = AllowedScripts.delete(domain: name) {
                                    ScriptsManager.reset    (for: name)
                                    ScriptsManager.resetIsOn(for: name)
                                }
                            }
                            Task { @MainActor in
                                PopupState.shared.onChangeMatch()
                            }
                        case .failure:
                            MessageBox.insert(
                                type: .error,
                                title: NSLocalizedString("Wildcard rule for the following domain was not removed:", comment: ""),
                                description: name.decodePunycode()
                            )
                    }

                }
            }

            Logger.customLog("onClick_ruleDelete()")
            AllowedDomains.dump()
        }
    }

}
