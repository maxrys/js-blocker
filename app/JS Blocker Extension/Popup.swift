
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    static let ICON_CLOUD    = Image(systemName: "cloud")
    static let ICON_SETTINGS = Image(systemName: "gearshape.fill")

    static let FRAME_WIDTH: CGFloat = 450

    @Environment(\.openURL) private var openURL

    @StateObject private var userDefaultsState = UserDefaultsState.shared
    @StateObject private var popupState        = PopupState.shared

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

            /* ############## */
            /* ### MARK: Body */
            /* ############## */

            VStack(spacing: 0) {

                if (self.popupState.match.isNoDomain) {
                    DomainRulePanel(
                        title: NSLocalizedString("JavaScript on the Domain", comment: ""),
                        rules:           [],
                        ruleIsActive:    false,
                        buttonIsEnabled: false,
                        selectedDefault: [],
                        buttonOnClick: { _ in }
                    )
                    DomainRulePanel(
                        title: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: ""),
                        rules:           [],
                        ruleIsActive:    false,
                        buttonIsEnabled: false,
                        selectedDefault: [],
                        buttonOnClick: { _ in }
                    )
                } else {
                    DomainRulePanel(
                        title: NSLocalizedString("JavaScript on the Domain", comment: ""),
                        rules:          [self.popupState.exactRule],
                        ruleIsActive:    self.popupState.match.isExact,
                        buttonIsEnabled: self.popupState.match.isNone,
                        selectedDefault: self.popupState.match.indices,
                        buttonOnClick: { _ in
                            ViewController.shared.onClick_ruleExactInsert()
                        }
                    )
                    DomainRulePanel(
                        title: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: ""),
                        rules:           self.popupState.wildcardRules,
                        ruleIsActive:    self.popupState.match.isWildcard,
                        buttonIsEnabled: self.popupState.match.isNone,
                        selectedDefault: self.popupState.match.indices,
                        buttonOnClick: { indices in
                            ViewController.shared.onClick_ruleWildcardInsert(
                                indices: indices
                            )
                        }
                    )
                }

            }
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(Color.popup.bodyBackground)

            /* MARK: Indicator "Cloud" */

            .overlayPolyfill(alignment: .topLeading) {
                if (self.userDefaultsState.icloudStatus) {
                    self.CloudIndicator()
                }
            }

            /* MARK: Button "Settings" */

            .overlayPolyfill(alignment: .topTrailing) {
                self.ButtonSettings()
            }

            /* ############## */
            /* ### MARK: Foot */
            /* ############## */

            self.ButtonCancelRule()
                .padding(31)
                .frame(maxWidth: .infinity)
                .background(Color.popup.footBackground)

        }
        .frame(width: self.frameWidth)
        .environment(\.layoutDirection, .leftToRight)
    }

    @ViewBuilder private func CloudIndicator() -> some View {
        Self.ICON_CLOUD
            .font(.system(size: 20))
            .foregroundPolyfill(Color.popup.buttonCloud)
            .padding(10)
    }

    @ViewBuilder private func ButtonSettings() -> some View {
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
        .padding(10)
    }

    @ViewBuilder private func ButtonCancelRule() -> some View {
        ButtonRound(
            title: NSLocalizedString("cancel rule", comment: ""),
            color: .blue,
            minWidth: 250,
            onClick: {
                ViewController.shared.onClick_ruleDelete()
            }
        ).disabled(
            self.popupState.match.isNone ||
            self.popupState.match.isNoDomain
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

fileprivate let single_exactRule = "example.com"
fileprivate let single_wildcardRules = [
    "*.example.com"
]

fileprivate let multi_exactRule = "sub3.sub2.sub1.example.com"
fileprivate let multi_wildcardRules = [
    "*.sub3.sub2.sub1.example.com",
         "*.sub2.sub1.example.com",
              "*.sub1.example.com",
                   "*.example.com"
]

struct Popup_noDomain_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .noDomain
            PopupState.shared.exactRule = ""
            PopupState.shared.wildcardRules = []
            MessageBox.insert(
                type: .warning,
                title: "\".noDomain\" example",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Single_none_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .none
            PopupState.shared.exactRule = single_exactRule
            PopupState.shared.wildcardRules = single_wildcardRules
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Exact rule for the following domain was removed:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Single_exact_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .exact
            PopupState.shared.exactRule = single_exactRule
            PopupState.shared.wildcardRules = single_wildcardRules
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Single_wildcard_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .wildcard(indices: [0])
            PopupState.shared.exactRule = single_exactRule
            PopupState.shared.wildcardRules = single_wildcardRules
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                description: ["*.example.com"].joined(separator: "\n"),
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Multi_none_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .none
            PopupState.shared.exactRule = multi_exactRule
            PopupState.shared.wildcardRules = multi_wildcardRules
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Wildcard rules for the following domains were removed:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Multi_exact_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .exact
            PopupState.shared.exactRule = multi_exactRule
            PopupState.shared.wildcardRules = multi_wildcardRules
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                description: "sub3.sub2.sub1.example.com",
                lifeTime: .infinity
            )
        }
    }
}

struct Popup_Multi_wildcard_Previews: PreviewProvider {
    static var previews: some View {
        Popup().onAppear {
            PopupState.shared.match = .wildcard(indices: [0, 2])
            PopupState.shared.exactRule = multi_exactRule
            PopupState.shared.wildcardRules = multi_wildcardRules
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                description: ["*.sub3.sub2.sub1.example.com", "*.sub1.example.com"].joined(separator: "\n"),
                lifeTime: .infinity
            )
        }
    }
}
