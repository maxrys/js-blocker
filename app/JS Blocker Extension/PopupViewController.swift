
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
    static var popupState = PopupState(
        onTick: PopupViewController.onTimerTick
    )

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

    func popupSizeUpdate() {
        let host = NSHostingController(rootView: Popup(state: Self.popupState)).view
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
        Self.formUpdate()
        self.popupSizeUpdate()
        #if DEBUG
            print("viewWillAppear()")
        #endif
    }

    /* ###################################################################### */

    static func onTimerTick(offset: Double) {
        Self.popupState.timer?.stopAndReset()
        Self.popupState.messages.removeAll()
        Self.shared.popupSizeUpdate()
    }

    static func messageShow(title: String, description: String = "", type: MessageType = .info) {
        Task {
            let newValue = MessageInfo(
                title: title,
                description: description,
                type: type
            )
            for message in Self.popupState.messages {
                if (message.hashValue == newValue.hashValue) {
                    return
                }
            }
            Self.popupState.messages.append(newValue)
            Self.shared.popupSizeUpdate()
            Self.popupState.timer?.start(
                tickInterval: Self.MESSAGE_LIFE_TIME
            )
        }
    }

    /* ###################################################################### */

    static func formUpdate() {
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
                    Self.popupState.isEnabledGlobalRule = true
                    Self.popupState.isEnabledRuleCancel = false
            }
        }
    }

    static func pageUpdate() {
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

    static func onClick_buttonRuleLocalInsert() {
        if let domainName = Self.domainName {
            WhiteDomains.insert(
                name: domainName,
                isGlobal: false
            )
            Self.formUpdate()
            Self.pageUpdate()
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

    static func onClick_buttonRuleGlobalInsert(indeces: [Int]) {
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
                Self.formUpdate()
                Self.pageUpdate()
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

    static func onClick_buttonRuleDelete() {
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
            Self.formUpdate()
            Self.pageUpdate()
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
