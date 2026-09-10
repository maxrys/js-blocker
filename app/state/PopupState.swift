
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI
import SafariServices

final class PopupState: ObservableObject {

    static let TIMER_DELAY: Double = 1.0

    static public private(set) var shared = PopupState()

    @Published var page: SFSafariPage? = nil
    @Published var domainName: CurrentDomainName? = nil
    @Published var match: MatchType? = nil

    @Published var ruleExact: String = ""
    @Published var rulesWildcard: [String] = []
    @Published var rulesWildcardSelected: Set<Int> = []

    @Published var lifetime: TimeInterval? = nil
    @Published var expireStatus: ExpireStatus = .notSetted

    @Published var scripts = Matrix2dArrOfStr() /* [CurrentDomainName: [FrameDomainName: [URLString]]] */

    private var timer: Timer.Custom!

    private /* singleton */ init() {
        self.timer = Timer.Custom(
            repeats: .infinity,
            delay: Self.TIMER_DELAY,
            onTick: self.onTimerTick
        )
    }

    private func onTimerTick(timer: Timer.Custom) {
        let newExpireStatus = self.match?.expireStatus ?? .notSetted
        if (self.expireStatus != newExpireStatus) {
            self.expireStatus  = newExpireStatus
        }
        if case .expired = self.expireStatus {
            if case .success(let affected) = ADModel.sanitize() {
                if (affected > 0) {
                    SFSafariApplication.reloadRules()
                    self.refresh()
                }
            }
        }
    }

    public func onSetScripts(domainName: DomainName, frameDomainName: DomainName, scripts: [URLString]) {
        Self.shared.scripts[domainName, frameDomainName] = scripts
    }

    public func onSetPageAndDomain(_ page: SFSafariPage, _ domainName: DomainName) {
        self.page = page
        self.domainName = domainName
        self.match = ADModel.matchType(name: domainName)
        self.ruleExact = domainName.decodePunycode()
        self.rulesWildcard = ([domainName] + domainName.topDomains(isDeleteTLD: true)).reduce(into: [String]()) { result, domain in result.append("*." + domain.decodePunycode()) }
        self.rulesWildcardSelected = []
        self.lifetime = nil
        self.expireStatus = self.match?.expireStatus ?? .notSetted
        self.refresh()
        self.jsGetScripts()
    }

    public func reset() {
        self.page = nil
        self.domainName = nil
        self.match = nil
        self.ruleExact = ""
        self.rulesWildcard = []
        self.rulesWildcardSelected = []
        self.lifetime = nil
        self.expireStatus = .notSetted
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
            self.expireStatus = self.match?.expireStatus ?? .notSetted
            self.lifetime = nil

        } else {
            self.reset()
        }
    }

    func jsGetScripts() {
        if let page       = self.page,
           let domainName = self.domainName {
                Logger.customLog("js:getScripts.request for \(domainName)")
                page.dispatchMessageToScript(
                    withName: "js:getScripts.request",
                    userInfo: [
                        "domain": domainName
                    ]
                )
        } else {
            Logger.customLog("jsGetScripts(): Page not found")
        }
    }

    func jsSetMatch() {
        if let page       = self.page,
           let domainName = self.domainName,
           let match      = self.match {
                let matchJSONValue = match.strictJSON
                Logger.customLog("js:setMatch for \(domainName): \(matchJSONValue)")
                page.dispatchMessageToScript(
                    withName: "js:setMatch",
                    userInfo: [
                        "domain": domainName,
                        "match" : matchJSONValue
                    ]
                )
        } else {
            Logger.customLog("jsSetMatch(): Page not found")
        }
    }

}
