
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

class ViewController: SFSafariExtensionViewController {

    static let shared = ViewController()

    override func viewWillAppear() {
        super.viewWillAppear()
        MessageBox.delete(address: Popup.messageBoxAddress,
            Popup.messageIDForCurrentOperation
        )
    }

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
        if let domain = PopupState.shared.domain, let match = PopupState.shared.match {

            let type: String? = {
                switch match {
                    case .noOne      : return MATCH_TYPE_STRING_EXACT
                    case .noOneScript: return MATCH_TYPE_STRING_EXACT_SCRIPT
                    default          : return nil
                }
            }()

            guard let type = type else {
                return
            }

            var success: [String] = []
            var failure: [String] = []

            switch AllowedDomains.insert(name: domain, type: type, expiresAt: PopupState.shared.lifetime.ifNil(defaultValue: 0) { value in Int64(Date.timestamp + value) } ) {
                case .failure: failure.append(domain.decodePunycode())
                case .success: success.append(domain.decodePunycode())
                    if (match.isNoOneScript) {
                        ScriptsCart.saveIsOnToStorage(for: domain)
                        ScriptsCart.resetIsOn()
                    }
            }

            /* message */
            if (success.count > 0) {
                MessageBox.insert(address: Popup.messageBoxAddress, .init(
                    ID: Popup.messageIDForCurrentOperation,
                    type: .ok,
                    title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                    description: success.joined(separator: "\n")
                ))
            }
            if (failure.count > 0) {
                MessageBox.insert(address: Popup.messageBoxAddress, .init(
                    ID: Popup.messageIDForCurrentOperation,
                    type: .error,
                    title: NSLocalizedString("Exact rule for the following domain was not added:", comment: ""),
                    description: failure.joined(separator: "\n")
                ))
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
        if let domain = PopupState.shared.domain, let match = PopupState.shared.match {
            if (selected.isEmpty) {

                MessageBox.insert(address: Popup.messageBoxAddress, .init(
                    ID: Popup.messageIDForCurrentOperation,
                    type: .error,
                    title: NSLocalizedString("At least 1 subdomain must be selected!", comment: "")
                ))

            } else {

                let type: String? = {
                    switch match {
                        case .noOne      : return MATCH_TYPE_STRING_WILDCARD
                        case .noOneScript: return MATCH_TYPE_STRING_WILDCARD_SCRIPT
                        default          : return nil
                    }
                }()

                guard let type = type else {
                    return
                }

                let domains = [domain] + domain.topDomains(isDeleteTLD: true)
                var success: [String] = []
                var failure: [String] = []

                for (index, name) in domains.enumerated() {
                    if (selected.contains(index)) {
                        switch AllowedDomains.insert(name: name, type: type, expiresAt: PopupState.shared.lifetime.ifNil(defaultValue: 0) { value in Int64(Date.timestamp + value) } ) {
                            case .failure: failure.append(name.decodePunycode())
                            case .success: success.append(name.decodePunycode())
                                if (match.isNoOneScript) {
                                    ScriptsCart.saveIsOnToStorage(for: name)
                                }
                        }
                    }
                }
                if (match.isNoOneScript) {
                    ScriptsCart.resetIsOn()
                }

                /* message */
                if (success.count > 0) {
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                        description: success.joined(separator: "\n")
                    ))
                }
                if (failure.count > 0) {
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .error,
                        title: NSLocalizedString("Wildcard rules for the following domains were not added:", comment: ""),
                        description: failure.joined(separator: "\n")
                    ))
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
        if let match = PopupState.shared.match, let item = match.item {

            switch AllowedDomains.delete([item.name]) {
                case .success:
                    if (match.isExact    || match.isExactScript   ) { MessageBox.insert(address: Popup.messageBoxAddress, .init(ID: Popup.messageIDForCurrentOperation, type: .ok, title: NSLocalizedString(   "Exact rule for the following domain was removed:", comment: ""), description: item.nameDecoded)) }
                    if (match.isWildcard || match.isWildcardScript) { MessageBox.insert(address: Popup.messageBoxAddress, .init(ID: Popup.messageIDForCurrentOperation, type: .ok, title: NSLocalizedString("Wildcard rule for the following domain was removed:", comment: ""), description: item.nameDecoded)) }
                    if (match.isSomeStoredScript) {
                        ScriptsManager.reset    (for: item.name)
                        ScriptsManager.resetIsOn(for: item.name)
                    }
                    Task { @MainActor in
                        PopupState.shared.onChangeMatch()
                    }
                case .failure:
                    if (match.isExact    || match.isExactScript   ) { MessageBox.insert(address: Popup.messageBoxAddress, .init(ID: Popup.messageIDForCurrentOperation, type: .error, title: NSLocalizedString(   "Exact rule for the following domain was not removed:", comment: ""), description: item.nameDecoded)) }
                    if (match.isWildcard || match.isWildcardScript) { MessageBox.insert(address: Popup.messageBoxAddress, .init(ID: Popup.messageIDForCurrentOperation, type: .error, title: NSLocalizedString("Wildcard rule for the following domain was not removed:", comment: ""), description: item.nameDecoded)) }
            }

            Logger.customLog("onClick_ruleDelete()")
            AllowedDomains.dump()
        }
    }

}
