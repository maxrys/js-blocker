
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

final class ScriptsManager {

    static func set(for domain: DomainName, _ frameDomain: DomainName, _ scripts: [URLString]) {
        PopupState.shared.scripts[domain, frameDomain] = scripts
    }

    static func reset(for domain: DomainName) {
        PopupState.shared.scripts[domain] = nil
    }

    static func loadIsOn(for domain: DomainName) {
        PopupState.shared.scriptsIsOn[domain] = [:]
        for script in AllowedScripts.selectByDomain(domain: domain) {
            PopupState.shared.scriptsIsOn[
                script.domain,
                script.frameDomain,
                script.url
            ] = true
        }
    }

    static func resetIsOn(for domain: DomainName) {
        PopupState.shared.scriptsIsOn[domain] = nil
    }

    static func getIsOn(for domain: DomainName, _ frameDomain: DomainName, _ script: URLString) -> Bool {
        PopupState.shared.scriptsIsOn[domain, frameDomain, script, default: false]
    }

    static func setIsOn(for domain: DomainName, _ frameDomain: DomainName, _ script: URLString, _ value: Bool) {
        var result: ExecuteResult = .failure
        if (value == true) { result = AllowedScripts.insert(domain: domain, frameDomain: frameDomain, url: script) }
        if (value != true) { result = AllowedScripts.delete(domain: domain, frameDomain: frameDomain, url: script) }
        if case .success = result {
            PopupState.shared.scriptsIsOn[domain, frameDomain, script] = value
        }
    }

}
