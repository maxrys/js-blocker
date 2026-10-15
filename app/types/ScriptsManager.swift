
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

enum ScriptsManager {

    static func set(for domain: DomainName, _ frameDomain: DomainName, _ scripts: [URLString]) {
        PopupState.shared.scripts[domain, frameDomain] = Array(Set(scripts))
    }

    static func reset(for domain: DomainName, _ frameDomain: DomainName? = nil) {
        if let frameDomain
             { PopupState.shared.scripts[domain, frameDomain] = nil }
        else { PopupState.shared.scripts[domain             ] = nil }
    }

    static func loadIsOn(for domain: DomainName) {
        PopupState.shared.scriptsIsOn[domain] = [:]
        for script in AllowedScripts.selectByDomain(domain: domain) {
            PopupState.shared.scriptsIsOn[
                script.domain,
                script.frameDomain,
                default: []
            ].insert(script.url)
        }
    }

    static func resetIsOn(for domain: DomainName) {
        PopupState.shared.scriptsIsOn[domain] = nil
    }

    static func getIsOn(for domain: DomainName, _ frameDomain: DomainName, _ script: URLString) -> Bool {
        PopupState.shared.scriptsIsOn[domain, frameDomain]?.contains(script) ?? false
    }

    static func setIsOn(for domain: DomainName, _ frameDomain: DomainName, _ script: URLString, _ value: Bool) {
        if (value == true) { if case .success = AllowedScripts.insert(domain: domain, frameDomain: frameDomain, url: script) { PopupState.shared.scriptsIsOn[domain, frameDomain, default: []].insert(script) }}
        if (value != true) { if case .success = AllowedScripts.delete(domain: domain, frameDomain: frameDomain, url: script) { PopupState.shared.scriptsIsOn[domain, frameDomain, default: []].remove(script) }}
    }

}
