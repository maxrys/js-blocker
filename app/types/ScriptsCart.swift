
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

enum ScriptsCart {

    static let DOMAIN_NAME = "-->scripts_cart_domain<--"

    static func getIsOn(_ frameDomain: DomainName, _ script: URLString) -> Bool {
        PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME, frameDomain]?.contains(script) ?? false
    }

    static func setIsOn(_ frameDomain: DomainName, _ script: URLString, _ value: Bool) {
        if (value == true) { PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME, frameDomain, default: []].insert(script) }
        if (value != true) { PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME, frameDomain, default: []].remove(script) }
    }

    static func saveIsOnToStorage(for domain: DomainName) {
        if case .success = (AllowedScripts.delete(domain: domain)) {
            if let scriptsByFrames = PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME] {
                for (frameDomain, scripts) in scriptsByFrames {
                    for script in scripts {
                        _ = AllowedScripts.insert(
                            domain: domain,
                            frameDomain: frameDomain,
                            url: script
                        )
                    }
                }
            }
        }
    }

    static func resetIsOn() {
        PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME] = nil
    }

}
