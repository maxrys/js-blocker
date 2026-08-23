
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    static let ICON_SCRIPTS  = Image(systemName: "applescript")
    static let ICON_SETTINGS = Image(systemName: "gearshape.fill")

    static let FRAME_WIDTH: CGFloat = 450

    @Environment(\.openURL) private var openURL

    @StateObject private var userDefaultsState = UserDefaultsState.shared
    @StateObject private var popupState        = PopupState.shared

    @State private var isShowScripts: Bool = false

    private let frameWidth: CGFloat
    private let messageBox: MessageBox

    init(frameWidth: CGFloat = Self.FRAME_WIDTH) {
        self.frameWidth = frameWidth
        self.messageBox = MessageBox()
    }

    public var body: some View {
        VStack(spacing: 0) {

            /* ################# */
            /* ### MARK: Message */
            /* ################# */

            self.messageBox

            /* #################### */
            /* ### MARK: Allow Rule */
            /* #################### */

            VStack(spacing: 0) {

                DomainRulePanel(
                    panelType: .exact,
                    onClickAllow: { _ in
                        ViewController.shared.onClick_ruleExactInsert(lifetime: self.popupState.lifetime)
                    }
                ).background(
                    Color.popup.ruleExactBackground
                        .opacity(0.9)
                )

                DomainRulePanel(
                    panelType: .wildcard,
                    onClickAllow: { selected in
                        ViewController.shared.onClick_ruleWildcardInsert(selected: selected, lifetime: self.popupState.lifetime)
                    }
                ).background(
                    Color.popup.rulesWildcardBackground
                        .opacity(0.9)
                )

            }.frame(maxWidth: .infinity)

            /* MARK: Extra Buttons */

            .overlayPolyfill(alignment: .topTrailing) {
                HStack(spacing: 5) {
                    if let realDomainName = self.popupState.domainName {
                        self.ButtonScriptsView()
                            .popover(isPresented: self.$isShowScripts, arrowEdge: .bottom) {
                                ScriptsPanel(
                                    realDomainName: realDomainName,
                                    scriptsByDomains: self.popupState.scripts[realDomainName] ?? [:]
                                )
                            }
                    }
                    self.ButtonSettingsView()
                }.padding(10)
            }

            /* ##################### */
            /* ### MARK: Cancel Rule */
            /* ##################### */

            self.ButtonCancelRuleView()
                .padding(31)
                .frame(maxWidth: .infinity)
                .background(
                    Color.popup.ruleCancelBackground
                        .opacity(0.9)
                )

        }
        .frame(width: self.frameWidth)
        .environment(\.layoutDirection, .leftToRight)
    }

    @ViewBuilder private func ButtonScriptsView() -> some View {
        Button {
            self.isShowScripts.toggle()
        } label: {
            Self.ICON_SCRIPTS
                .font(.system(size: 20))
                .foregroundPolyfill(Color.popup.buttonSettings)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
        .focusable(false)
    }

    @ViewBuilder private func ButtonSettingsView() -> some View {
        Button {
            openURL(
                URL(string: "jsBlocker://")!
            )
        } label: {
            Self.ICON_SETTINGS
                .font(.system(size: 20))
                .foregroundPolyfill(Color.popup.buttonSettings)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
        .focusable(false)
    }

    @ViewBuilder private func ButtonCancelRuleView() -> some View {
        ButtonCapsule(
            title: NSLocalizedString("cancel rule", comment: ""),
            style: .blue,
            minWidth: 250,
            onClick: {
                ViewController.shared.onClick_ruleDelete()
            }
        ).disabled(
            self.popupState.match.ifNil(defaultValue: true) { match in
                !match.isSome
            }
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct Popup_MatchNone_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = nil
            PopupState.shared.ruleExact = ""
            PopupState.shared.rulesWildcard = []
            MessageBox.insert(
                type: .warning,
                title: "\".none\" example",
                lifeTime: .infinity
            )
        }
    }
}

/* ### TopDomain ############################################### */

struct Popup_TopDomain_MatchNoOne_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .noOne
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Exact rule for the following domain was removed:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_TopDomain_MatchExact_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_TopDomain_MatchWildcard_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                description: ["*.example.com"].joined(separator: "\n"),
                lifeTime: .infinity
            )
        }
    }
}

/* ### Subdomain ############################################### */

struct Popup_Subdomain_MatchNoOne_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .noOne
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_SUBDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_SUBDOMAIN
            PopupState.shared.rulesWildcardSelected = []
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Wildcard rules for the following domains were removed:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Subdomain_MatchExact_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_SUBDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_SUBDOMAIN
            PopupState.shared.rulesWildcardSelected = []
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                description: "sub3.sub2.sub1.example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Subdomain_MatchWildcard_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_SUBDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_SUBDOMAIN
            PopupState.shared.rulesWildcardSelected = [0, 2]
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                description: ["*.sub3.sub2.sub1.example.com", "*.sub1.example.com"].joined(separator: "\n"),
                lifeTime: .infinity
            )
        }
    }
}
