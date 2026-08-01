
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI
import SafariServices

final class PopupState: ObservableObject {

    static public private(set) var shared = PopupState()

    @Published var page: SFSafariPage? = nil
    @Published var domainName: DomainName? = nil
    @Published var match: MatchType? = nil
    @Published var ruleExact: String = ""
    @Published var rulesWildcard: [String] = []
    @Published var rulesWildcardSelected: Set<Int> = []
    @Published var lifetime: TimeInterval = LifetimePicker.PERIOD_UNLIMIT
    @Published var expireStatus: ExpireStatus = .notSetted

    private var timer: Timer.Custom!

    public func reset() {
        self.page = nil
        self.domainName = nil
        self.match = nil
        self.ruleExact = ""
        self.rulesWildcard = []
        self.rulesWildcardSelected = []
        self.lifetime = LifetimePicker.PERIOD_UNLIMIT
        self.expireStatus = .notSetted
    }

    public func setPageAndDomain(_ page: SFSafariPage, _ domainName: DomainName) {
        self.page = page
        self.domainName = domainName
        self.match = ADModel.matchType(name: domainName)
        self.ruleExact = domainName.decodePunycode()
        self.rulesWildcard = ([domainName] + domainName.topDomains(isDeleteTLD: true)).reduce(into: [String]()) { result, domain in result.append("*." + domain.decodePunycode()) }
        self.rulesWildcardSelected = []
        self.lifetime = LifetimePicker.PERIOD_UNLIMIT
        self.expireStatus = self.match?.expireStatus ?? .notSetted
        self.refresh()
    }

    public func refresh() {
        if let domainName = self.domainName {

            var wildcardRulesSelected: Set<Int> = []
            let wildcardDomains: [DomainName] = [domainName] + domainName.topDomains(isDeleteTLD: true)
            let wildcardDomainsInStorage: [String] = ADModel.selectWildcardDomains(domainName).map {
                domainInfo in domainInfo.name
            }

            if (wildcardDomains.count == 1) {
                wildcardRulesSelected = [0]
            } else {
                for (index, domain) in wildcardDomains.enumerated() {
                    if (wildcardDomainsInStorage.contains(domain)) {
                        wildcardRulesSelected.insert(index)
                    }
                }
            }

            self.match = ADModel.matchType(name: domainName)
            self.rulesWildcardSelected = wildcardRulesSelected
            self.lifetime = LifetimePicker.PERIOD_UNLIMIT
            self.expireStatus = self.match?.expireStatus ?? .notSetted

        } else {
            self.reset()
        }
    }

    func pageReload() {
        if let page       = self.page,
           let domainName = self.domainName,
           let match      = self.match {
               page.dispatchMessageToScript(
                   withName: "onChangeMatch",
                   userInfo: [
                       "domain": domainName,
                       "match" : match.toStrictJS
                   ]
               )
        } else {
            Logger.customLog("pageReload(): Page not found")
        }
    }

    private /* singleton */ init() {
        self.timer = Timer.Custom(
            repeats: .infinity,
            delay: 1,
            onTick: self.onTimerTick
        )
    }

    private func onTimerTick(timer: Timer.Custom) {
        let newExpireStatus = self.match?.expireStatus ?? .notSetted
        if (self.expireStatus != newExpireStatus) {
            self.expireStatus  = newExpireStatus
        }
        if case .expired = self.expireStatus {
            if case .success(let affected) = ADModel.sanitize(), affected > 0 {
                self.refresh()
                self.pageReload()
            }
        }
    }

}
