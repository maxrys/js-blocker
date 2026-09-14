
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

final class ScriptsCart {

    static let DOMAIN_NAME = "-->scripts_cart_domain<--"

    static func getIsOn(_ frameDomain: DomainName, _ script: URLString) -> Bool {
        PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME, frameDomain, script, default: false]
    }

    static func setIsOn(_ frameDomain: DomainName, _ script: URLString, _ value: Bool) {
        PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME, frameDomain, script] = value
    }

    static func saveIsOnToStorage(for domain: DomainName) {
        if case .success = (AllowedScripts.delete(domain: domain)) {
            if let scriptsByFrames = PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME] {
                for (frameDomainName, scripts) in scriptsByFrames {
                    for (script, isOn) in scripts {
                        if (isOn) {
                            _ = AllowedScripts.insert(
                                domain: domain,
                                frameDomain: frameDomainName,
                                url: script
                            )
                        }
                    }
                }
            }
        }
    }

    static func resetIsOn() {
        PopupState.shared.scriptsIsOn[Self.DOMAIN_NAME] = nil
    }

}
