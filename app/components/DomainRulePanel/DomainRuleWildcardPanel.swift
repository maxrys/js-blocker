
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRuleWildcardPanel: View {

    @StateObject private var popupState = PopupState.shared

    private var colorDomainName: Color {
        if (self.isActiveRule && !self.rules.isEmpty)
             { return Color.domainRulePanel.nameActive }
        else { return Color.domainRulePanel.name }
    }

    private var colorBorder: Color {
        if (self.isActiveRule && !self.rules.isEmpty)
             { return Color.domainRulePanel.borderActive }
        else { return Color.domainRulePanel.border }
    }

    private var colorBackground: Color {
        Color.domainRulePanel.background
    }

    private var isActiveRule: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isWildcard || match.isWildcardScript
        }
    }

    private var isEnabledButton: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isNoOneScript
        }
    }

    private var isEnabledByScriptButton: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isNoOneScript || match.isWildcardScript
        }
    }

    private var isByScriptMode: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOneScript || match.isWildcardScript
        }
    }

    private var rules: [String] {
        self.popupState.rulesWildcard
    }

    private var rulesSelected: Binding<Set<Int>> {
        self.$popupState.rulesWildcardSelected
    }

    private var rulesDisabled: Binding<Set<Int>> {
        self.$popupState.rulesWildcardDisabled
    }

    private var lifetime: Binding<TimeInterval?> {
        self.$popupState.lifetime
    }

    private let onClickAllow: (Set<Int>) -> Void

    init(onClickAllow: @escaping (Set<Int>) -> Void = { _ in }) {
        self.onClickAllow = onClickAllow
    }

    public var body: some View {
        VStack(spacing: 13) {

            /* MARK: Title */

            self.TitleView(
                NSLocalizedString("JavaScript on the Domain + Subdomains", comment: "")
            )

            /* MARK: Domain selector */

            VStack(alignment: .trailing, spacing: 5) {
                if (self.rules.isEmpty) {

                    self.DomainNameView(
                        text: NSLocalizedString("...loading...", comment: ""),
                        opacity: 0.5
                    )

                } else {

                    ForEach(self.rules.indices, id: \.self) { index in
                        HStack(spacing: 10) {

                            let isFirstSelected = self.rulesSelected.wrappedValue.sorted(by: <).first == index
                            let isDisabled      = self.rulesDisabled.wrappedValue.contains(index)

                            let opacity: CGFloat = {
                                switch self.popupState.match {
                                    case .noOne         : isDisabled      ? 0.5 : 1.0
                                    case .noOneScript   : isDisabled      ? 0.5 : 1.0
                                    case .wildcard      : isFirstSelected ? 1.0 : 0.5
                                    case .wildcardScript: isFirstSelected ? 1.0 : 0.5
                                    default: 0.5
                                }
                            }()

                            self.DomainNameView(
                                text: self.rules[index],
                                opacity: opacity
                            )

                            if (self.rules.count > 1) {
                                DomainRuleWildcardPanel_Checkbox(
                                    selected: self.rulesSelected,
                                    index: index,
                                    color: self.colorDomainName
                                ).disabled(
                                    !self.isEnabledButton || isDisabled
                                )
                            }

                        }
                    }

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
                title: self.isByScriptMode ?
                    NSLocalizedString("allow by scripts", comment: "") :
                    NSLocalizedString("allow"           , comment: ""),
                minWidth: isByScriptMode ? 250 : 200,
                onClick: {
                    self.onClickAllow(
                        self.rulesSelected.wrappedValue
                    )
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

struct DomainRuleWildcardPanel_Checkbox: View {

    static let ICON_CHECK         = Image("symbol Checkbox")
    static let ICON_CHECK_CHECKED = Image("symbol Checkbox Checked")

    @Environment(\.isEnabled) private var isEnabled

    private let selected: Binding<Set<Int>>
    private let index: Int
    private let color: Color

    init(selected: Binding<Set<Int>>, index: Int, color: Color) {
        self.selected = selected
        self.index = index
        self.color = color
    }

    public var body: some View {
        Button {
            self.selected.wrappedValue.toggle(index)
        } label: {
            let icon = self.selected.wrappedValue.contains(index) ?
                Self.ICON_CHECK_CHECKED :
                Self.ICON_CHECK
            icon.foregroundPolyfill(self.color)
                .font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .disabled(!self.isEnabled)
        .pointerStyleLinkPolyfill(
            self.isEnabled
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct DomainRuleWildcardPanel_Previews: PreviewProvider {

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
                case 4:
                    PopupState.shared.match = .noOne
                    PopupState.shared.ruleExact = DEMO_RULE__SUBDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__SUBDOMAIN
                    PopupState.shared.rulesWildcardSelected = []
                    PopupState.shared.rulesWildcardDisabled = [2, 3]
                case 5:
                    PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
                    PopupState.shared.ruleExact = DEMO_RULE__SUBDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__SUBDOMAIN
                    PopupState.shared.rulesWildcardSelected = []
                    PopupState.shared.rulesWildcardDisabled = []
                case 6:
                    PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
                    PopupState.shared.ruleExact = DEMO_RULE__SUBDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__SUBDOMAIN
                    PopupState.shared.rulesWildcardSelected = [0, 2]
                    PopupState.shared.rulesWildcardDisabled = []
                default: break
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                DomainRuleWildcardPanel()
                    .background(Color.popup.ruleExactBackground)
                PreviewModeSelector(
                    title: "match",
                    state: Self.match,
                    modes: [
                        "nil", "noOne", "exact", "wildcard", "N+", "E+", "W+"
                    ]
                )
                Spacer()
            }.frame(
                width: Popup.FRAME_WIDTH,
                height: 400
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
