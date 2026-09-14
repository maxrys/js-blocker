
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
    @Published var rulesWildcardDisabled: Set<Int> = []

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

    public func initEmpty() {
        self.page = nil
        self.domainName = nil
        self.match = nil
        self.ruleExact = ""
        self.rulesWildcard = []
        self.rulesWildcardSelected = []
        self.rulesWildcardDisabled = []
        self.expireStatus = .notSetted
        self.lifetime = nil
    }

    public func onChangePageAndDomain(_ page: SFSafariPage, _ domainName: DomainName) {
        self.page = page
        self.domainName = domainName
        self.ruleExact = domainName.decodePunycode()
        self.rulesWildcard = ([domainName] + domainName.topDomains(isDeleteTLD: true)).reduce(into: [String]()) { result, domain in
            result.append("*." + domain.decodePunycode())
        }
        self.jsGetScripts()
    }

    public func onChangeMatch() {
        if let _          = self.page,
           let domainName = self.domainName {

            let allDomains: [DomainName] = [domainName] + domainName.topDomains(isDeleteTLD: true)

            let rulesWildcardSelected: Set<Int> = {
                if (allDomains.count == 1) {
                    return [0]
                }
                return AllowedDomains.selectDomainAndTopDomains(domainName, types: [
                    MATCH_TYPE_STRING_WILDCARD,
                    MATCH_TYPE_STRING_WILDCARD_SCRIPT
                ]).reduce(into: Set<Int>()) { result, domain in
                    if let index = allDomains.firstIndex(of: domain.name) {
                        result.insert(index)
                    }
                }
            }()

            let rulesWildcardDisabled: Set<Int> = {
                AllowedDomains.selectDomainAndTopDomains(domainName, types: [
                    MATCH_TYPE_STRING_EXACT,
                    MATCH_TYPE_STRING_EXACT_SCRIPT,
                    MATCH_TYPE_STRING_WILDCARD,
                    MATCH_TYPE_STRING_WILDCARD_SCRIPT,
                ]).reduce(into: Set<Int>()) { result, domain in
                    if let index = allDomains.firstIndex(of: domain.name) {
                        result.insert(index)
                    }
                }
            }()

            self.match = AllowedDomains.matchType(name: domainName)
            self.rulesWildcardSelected = rulesWildcardSelected
            self.rulesWildcardDisabled = rulesWildcardDisabled
            self.expireStatus = self.match?.expireStatus ?? .notSetted
            self.lifetime = nil

            SFSafariApplication.reloadRules()
            self.jsSetMatch()

        } else {
            self.initEmpty()
        }
    }

    private func onTimerTick(timer: Timer.Custom) {
        let newExpireStatus = self.match?.expireStatus ?? .notSetted
        if (self.expireStatus != newExpireStatus) {
            self.expireStatus  = newExpireStatus
        }
        if case .expired = self.expireStatus {
            if case .success(let affected) = AllowedDomains.sanitize() {
                if (affected > 0) {
                    self.onChangeMatch()
                }
            }
        }
    }

    public func onSetScripts(domainName: DomainName, frameDomainName: DomainName, scripts: [URLString]) {
        Self.shared.scripts[domainName, frameDomainName] = scripts
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
