
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRuleExactPanel: View {

    @StateObject private var popupState = PopupState.shared

    private var colorDomainName: Color {
        if (self.isActiveRule && !self.rule.isEmpty)
             { return Color.domainRulePanel.nameActive }
        else { return Color.domainRulePanel.name }
    }

    private var colorBorder: Color {
        if (self.isActiveRule && !self.rule.isEmpty)
             { return Color.domainRulePanel.borderActive }
        else { return Color.domainRulePanel.border }
    }

    private var colorBackground: Color {
        Color.domainRulePanel.background
    }

    private var isActiveRule: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isExact || match.isExactScript
        }
    }

    private var isEnabledButton: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isNoOneScript
        }
    }

    private var isEnabledByScriptButton: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isNoOneScript || match.isExactScript
        }
    }

    private var isByScriptMode: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOneScript || match.isExactScript
        }
    }

    private var rule: String {
        self.popupState.ruleExact
    }

    private var lifetime: Binding<TimeInterval?> {
        self.$popupState.lifetime
    }

    private let onClickAllow: () -> Void

    init(onClickAllow: @escaping () -> Void = { }) {
        self.onClickAllow = onClickAllow
    }

    public var body: some View {
        VStack(spacing: 13) {

            /* MARK: Title */

            self.TitleView(
                NSLocalizedString("JavaScript on the Domain", comment: "")
            )

            /* MARK: Domain selector */

            VStack(alignment: .trailing, spacing: 5) {
                if (self.rule.isEmpty) {

                    self.DomainNameView(
                        text: NSLocalizedString("...loading...", comment: ""),
                        opacity: 0.5
                    )

                } else {

                    self.DomainNameView(
                        text: self.rule,
                        opacity: self.isActiveRule || self.isEnabledButton ? 1.0 : 0.5
                    )

                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.colorBorder, lineWidth: 4)
                    .background(self.colorBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )

            /* MARK: LifetimeInfo */

            if (self.isActiveRule && self.popupState.expireStatus.isSome) {
                LifetimeInfo()
            }

            /* MARK: Button "Allow" */

            self.ButtonAllowView()

        }
        .padding(.horizontal, 20)
        .padding(.vertical  , 30)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func TitleView(_ textLocalized: String) -> some View {
        Text(textLocalized)
            .font(.system(size: 14, weight: .bold))
    }

    @ViewBuilder private func DomainNameView(text: String, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundPolyfill(self.colorDomainName)
            .opacity(opacity)
    }

    @ViewBuilder private func ButtonAllowView() -> some View {
        Group {
            ButtonCapsule(
                title: isByScriptMode ?
                    NSLocalizedString("allow by scripts", comment: "") :
                    NSLocalizedString("allow"           , comment: ""),
                minWidth: isByScriptMode ? 250 : 200,
                onClick: {
                    self.onClickAllow()
                }
            ).disabled(
                !self.isEnabledButton
            )
        }
        .overlayPolyfill(alignment: .leading) {
            if (self.isEnabledByScriptButton) {
                if let domainName = self.popupState.domainName {
                    ScriptsPanel(
                        domainName: domainName,
                        openerIconOffset: CGPoint(x: 2, y: 0)
                    )
                }
            }
        }
        .overlayPolyfill(alignment: .trailing) {
            if (self.isEnabledButton) {
                LifetimePicker(
                    lifetime: self.lifetime,
                    openerIconOffset: CGPoint(x: -1.0, y: -0.5)
                )
            }
        }
        .clipShape   (Capsule())
        .contentShape(Capsule())
        .focusEffect (Capsule())
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct DomainRuleExactPanel_Previews: PreviewProvider {

    struct ViewWithState: View {

        @ObservedObject static private var match = ValueState<UInt>(0) { value in
            switch value {
                case 0:
                    PopupState.shared.match = nil
                    PopupState.shared.ruleExact = ""
                    PopupState.shared.rulesWildcard = []
                case 1:
                    PopupState.shared.match = .noOne
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                case 2:
                    PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                case 3:
                    PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                default: break
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                DomainRuleExactPanel()
                    .background(Color.popup.ruleExactBackground)
                PreviewModeSelector(
                    title: "match",
                    state: Self.match,
                    modes: ["nil", "noOne", "exact", "wildcard"]
                )
            }.frame(
                width: Popup.FRAME_WIDTH
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
