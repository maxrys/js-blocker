
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

class SafariExtensionViewController: SFSafariExtensionViewController {

    static var MESSAGE_LIFE_TIME: Double = 1.0

    static var page: SFSafariPage?
    static var domainName: String?
    static var blockingState: BlockingType = .none
    static var state = PopupState(
        onTick: SafariExtensionViewController.onTimerTick
    )

    static let shared: SafariExtensionViewController = {
        return SafariExtensionViewController()
    }()

    static var popupShared: Popup = {
        return Popup(
            state: SafariExtensionViewController.state
        )
    }()

    var popupView: NSView!

    /* ###################################################################### */

    func popupSizeUpdate() {
        let host = NSHostingController(rootView: Popup(state: Self.state)).view
        self.popupView.frame      = CGRect(x: 0, y: 0, width: Int(host.intrinsicContentSize.width), height: Int(host.intrinsicContentSize.height))
        self.preferredContentSize = CGSize(            width: Int(host.intrinsicContentSize.width), height: Int(host.intrinsicContentSize.height))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.popupView = NSHostingController(rootView: Self.popupShared).view
        self.view.addSubview(self.popupView)
        #if DEBUG
            WhiteDomains.dump()
        #endif
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.formUpdate()
        self.popupSizeUpdate()
    }

    /* ###################################################################### */

    static func onTimerTick(offset: Double) {
        Self.state.timer?.stopAndReset()
        Self.state.messages.removeAll()
        Self.shared.popupSizeUpdate()
    }

    static func messageShow(title: String, description: String = "", type: MessageType = .info) {
        DispatchQueue.main.async {
            let newValue = MessageInfo(
                title: title,
                description: description,
                type: type
            )
            for message in Self.state.messages {
                if (message.hashValue == newValue.hashValue) {
                    return
                }
            }
            Self.state.messages.append(newValue)
            Self.shared.popupSizeUpdate()
            Self.state.timer?.start(
                tickInterval: Self.MESSAGE_LIFE_TIME
            )
        }
    }

    /* ###################################################################### */

    func formUpdate() {
        Self.state.reset()

        if let domainName = Self.domainName {

            Self.blockingState = WhiteDomains.blockingState(
                name: domainName
            )

            /* MARK: local rule */
            Self.state.indecesForLocal = [0]
            Self.state.rulesForLocal = [
                domainName.decodePunycode()
            ]

            /* MARK: global rules */
            Self.state.indecesForGLobal = []
            Self.state.rulesForGlobal = []

            let domainsInDB: [String] = WhiteDomains.selectGlobalDomains(domainName).map {
                domainInfo in domainInfo.name
            }

            var domains: [String] = [domainName] + domainName.topDomains()
            domains.removeLast() /* delete TLD (top-level domain), eg ".com", ".net" … */

            for (index, domain) in domains.enumerated() {
                if (domainsInDB.contains(domain)) {
                    Self.state.indecesForGLobal.append(
                        index
                    )
                }
                Self.state.rulesForGlobal.append(
                    "*." + domain.decodePunycode()
                )
            }

            if (domains.count == 1) {
                Self.state.indecesForGLobal = [0]
            }

            /* MARK: states of popup elements */
            switch Self.blockingState {
                case .local:
                    Self.state.isActiveLocalRule = true
                    Self.state.isActiveGlobalRule = false
                    Self.state.isEnabledLocalRule = false
                    Self.state.isEnabledGlobalRule = false
                    Self.state.isEnabledRuleCancel = true
                case .global:
                    Self.state.isActiveLocalRule = false
                    Self.state.isActiveGlobalRule = true
                    Self.state.isEnabledLocalRule = false
                    Self.state.isEnabledGlobalRule = false
                    Self.state.isEnabledRuleCancel = true
                case .none:
                    Self.state.isActiveLocalRule = false
                    Self.state.isActiveGlobalRule = false
                    Self.state.isEnabledLocalRule = true
                    Self.state.isEnabledGlobalRule = true
                    Self.state.isEnabledRuleCancel = false
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
            #if DEBUG
                print("pageUpdate(): Page not found")
            #endif
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
                Self.messageShow(
                    title: NSLocalizedString("Permission for the following domain was added:", comment: ""),
                    description: success.joined(separator: "\n"),
                    type: .ok
                )
            }
            if (failure.count > 0) {
                Self.messageShow(
                    title: NSLocalizedString("Permission for the following domain was not added:", comment: ""),
                    description: failure.joined(separator: "\n"),
                    type: .error
                )
            }

            /* ui update */
            if (success.count > 0) {
                self.formUpdate()
                self.pageUpdate()
            }

            #if DEBUG
                print("onClick_buttonRuleLocalInsert()")
                WhiteDomains.dump()
            #endif
        }
    }

    func onClick_buttonRuleGlobalInsert(indeces: [Int]) {
        if let domainName = Self.domainName {
            if (indeces.isEmpty) {

                Self.messageShow(
                    title: NSLocalizedString("At least 1 subdomain must be selected!", comment: ""),
                    type: .error
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
                    Self.messageShow(
                        title: NSLocalizedString("Global permissions for the following domains were added:", comment: ""),
                        description: success.joined(separator: "\n"),
                        type: .ok
                    )
                }
                if (failure.count > 0) {
                    Self.messageShow(
                        title: NSLocalizedString("Global permissions for the following domains were not added:", comment: ""),
                        description: failure.joined(separator: "\n"),
                        type: .error
                    )
                }

                /* ui update */
                if (success.count > 0) {
                    self.formUpdate()
                    self.pageUpdate()
                }
            }

            #if DEBUG
                print("onClick_buttonRuleGlobalInsert()")
                WhiteDomains.dump()
            #endif
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
                    Self.messageShow(
                        title: NSLocalizedString("Permission for the following domain was removed:", comment: ""),
                        description: success.joined(separator: "\n"),
                        type: .ok
                    )
                }
                if (failure.count > 0) {
                    Self.messageShow(
                        title: NSLocalizedString("Permission for the following domain was not removed:", comment: ""),
                        description: failure.joined(separator: "\n"),
                        type: .error
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
                    Self.messageShow(
                        title: NSLocalizedString("Global permissions for the following domains were removed:", comment: ""),
                        description: success.joined(separator: "\n"),
                        type: .ok
                    )
                }
                if (failure.count > 0) {
                    Self.messageShow(
                        title: NSLocalizedString("Global permissions for the following domains were not removed:", comment: ""),
                        description: failure.joined(separator: "\n"),
                        type: .error
                    )
                }
            }

            /* ui update */
            if (success.count > 0) {
                self.formUpdate()
                self.pageUpdate()
            }

            #if DEBUG
                print("onClick_buttonRuleDelete()")
                WhiteDomains.dump()
            #endif
        }
    }

}
