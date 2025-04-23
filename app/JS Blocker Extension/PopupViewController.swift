
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

class PopupViewController: SFSafariExtensionViewController {

    static var MESSAGE_LIFE_TIME: Double = 1.0

    static var page: SFSafariPage?
    static var domainName: String?
    static var blockingState: BlockingType = .none
    static var state = PopupState(
        onTick: PopupViewController.onTimerTick
    )

    static let shared: PopupViewController = {
        return PopupViewController()
    }()

    static var popupShared: Popup = {
        return Popup(
            state: PopupViewController.state
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
            print("viewDidLoad(): DB path = \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.formUpdate()
        self.popupSizeUpdate()
        #if DEBUG
            print("viewWillAppear()")
        #endif
    }

    /* ###################################################################### */

    static func onTimerTick(offset: Double) {
        Self.state.timer?.stopAndReset()
        Self.state.messages.removeAll()
        Self.shared.popupSizeUpdate()
    }

    static func messageShow(title: String, description: String = "", type: MessageType = .info) {
        Task {
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
            WhiteDomains.insert(
                name: domainName,
                isGlobal: false
            )
            self.formUpdate()
            self.pageUpdate()
            Self.messageShow(
                title: NSLocalizedString("Settings have been saved.", comment: ""),
                type: .ok
            )
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
                for index in indeces {
                    if (index < domains.count) {
                        WhiteDomains.insert(
                            name: domains[index],
                            isGlobal: true
                        )
                    }
                }
                self.formUpdate()
                self.pageUpdate()
                Self.messageShow(
                    title: NSLocalizedString("Settings have been saved.", comment: ""),
                    type: .ok
                )
            }
            #if DEBUG
                print("onClick_buttonRuleGlobalInsert()")
                WhiteDomains.dump()
            #endif
        }
    }

    func onClick_buttonRuleDelete() {
        if let domainName = Self.domainName {
            switch Self.blockingState {
                case .local:
                    WhiteDomains.selectByName(domainName)?.delete()
                case .global:
                    WhiteDomains.selectGlobalDomains(domainName).forEach { topDomain in
                        topDomain.delete()
                    }
                case .none:
                    break /* impossible case */
            }
            self.formUpdate()
            self.pageUpdate()
            Self.messageShow(
                title: NSLocalizedString("Settings have been saved.", comment: ""),
                type: .ok
            )
            #if DEBUG
                print("onClick_buttonRuleDelete()")
                WhiteDomains.dump()
            #endif
        }
    }

}
