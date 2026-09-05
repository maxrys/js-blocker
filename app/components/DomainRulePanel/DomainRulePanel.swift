
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRulePanel: View {

    enum PanelType {
        case exact
        case wildcard
    }

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

    private var titleLocalized: String {
        switch self.panelType {
            case .exact   : NSLocalizedString("JavaScript on the Domain"             , comment: "")
            case .wildcard: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: "")
        }
    }

    private var rules: [String] {
        switch self.panelType {
            case .exact   : self.popupState.ruleExact.isEmpty ? [] : [self.popupState.ruleExact]
            case .wildcard: self.popupState.rulesWildcard
        }
    }

    private var isActiveRule: Bool {
        switch self.panelType {
            case .exact   : self.popupState.match.ifNil(defaultValue: false) { match in match.isExact    }
            case .wildcard: self.popupState.match.ifNil(defaultValue: false) { match in match.isWildcard }
        }
    }

    private var isEnabledButton: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne
        }
    }

    private var selected: Binding<Set<Int>> {
        switch self.panelType {
            case .exact   : Binding.constant([])
            case .wildcard: self.$popupState.rulesWildcardSelected
        }
    }

    private var lifetime: Binding<TimeInterval?> {
        self.$popupState.lifetime
    }

    private let panelType: PanelType
    private let onClickAllow: (Set<Int>) -> Void

    init(panelType: PanelType, onClickAllow: @escaping (Set<Int>) -> Void = { _ in }) {
        self.panelType = panelType
        self.onClickAllow = onClickAllow
    }

    public var body: some View {
        VStack(spacing: 13) {

            /* MARK: Title */

            Text(self.titleLocalized)
                .font(.system(size: 14, weight: .bold))

            /* MARK: Domain selector */

            VStack(alignment: .trailing, spacing: 5) {
                if (self.rules.isEmpty) {

                    self.DomainNameView(
                        text: NSLocalizedString("...loading...", comment: ""),
                        opacity: 0.5
                    )

                } else if (self.rules.count == 1) {

                    self.DomainNameView(
                        text: self.rules.first!,
                        opacity:
                            self.isActiveRule || self.isEnabledButton ?
                                1.0 :
                                0.5
                    )

                } else {

                    ForEach(self.rules.indices, id: \.self) { index in
                        HStack(spacing: 10) {

                            let isChecked = self.selected.wrappedValue.contains(index)

                            self.DomainNameView(
                                text: self.rules[index],
                                opacity: isChecked || self.isEnabledButton ? 1.0 : 0.5
                            )

                            DomainRulePanel_Checkbox(
                                selected: self.selected,
                                index: index,
                                color: self.colorDomainName
                            ).disabled(!self.isEnabledButton)

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
                .disabled(
                    !self.isEnabledButton
                )

        }
        .padding(.horizontal, 20)
        .padding(.vertical  , 30)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func DomainNameView(text: String, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundPolyfill(self.colorDomainName)
            .opacity(opacity)
    }

    @ViewBuilder private func ButtonAllowView() -> some View {
        ButtonCapsule(
            title: NSLocalizedString("allow", comment: ""),
            minWidth: 180,
            onClick: {
                self.onClickAllow(
                    self.rules.count == 1 ? [0] : self.selected.wrappedValue
                )
            }
        ).overlayPolyfill(alignment: .trailing) {
            if (self.isEnabledButton) {
                LifetimePicker(
                    lifetime: self.lifetime,
                    openerIconOffset: CGPoint(x: -1.0, y: -0.5)
                ).disabled(!self.isEnabledButton)
            }
        }
        .clipShape   (Capsule())
        .contentShape(Capsule())
        .focusEffect (Capsule())
    }

}

struct DomainRulePanel_Checkbox: View {

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

struct DomainRulePanel_MatchNone_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) {
            DomainRulePanel(panelType: .exact   ).background(Color.popup.ruleExactBackground)
            DomainRulePanel(panelType: .wildcard).background(Color.popup.rulesWildcardBackground)
        }
        .frame(width: Popup.FRAME_WIDTH)
        .onAppear {
            PopupState.shared.match = nil
            PopupState.shared.ruleExact = ""
            PopupState.shared.rulesWildcard = []
        }
    }
}

struct DomainRulePanel_MatchNoOne_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) {
            DomainRulePanel(panelType: .exact   ).background(Color.popup.ruleExactBackground)
            DomainRulePanel(panelType: .wildcard).background(Color.popup.rulesWildcardBackground)
        }
        .frame(width: Popup.FRAME_WIDTH)
        .onAppear {
            PopupState.shared.match = .noOne
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
        }
    }
}

struct DomainRulePanel_MatchExact_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) {
            DomainRulePanel(panelType: .exact   ).background(Color.popup.ruleExactBackground)
            DomainRulePanel(panelType: .wildcard).background(Color.popup.rulesWildcardBackground)
        }
        .frame(width: Popup.FRAME_WIDTH)
        .onAppear {
            PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
        }
    }
}

struct DomainRulePanel_MatchWildcard_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) {
            DomainRulePanel(panelType: .exact   ).background(Color.popup.ruleExactBackground)
            DomainRulePanel(panelType: .wildcard).background(Color.popup.rulesWildcardBackground)
        }
        .frame(width: Popup.FRAME_WIDTH)
        .onAppear {
            PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
            PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
        }
    }
}
