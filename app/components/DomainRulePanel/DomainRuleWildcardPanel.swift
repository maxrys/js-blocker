
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
            match.isNoOne
        }
    }

    private var isEnabledButton_byScript: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isWildcardScript
        }
    }

    private var rules: [String] {
        self.popupState.rulesWildcard
    }

    private var selected: Binding<Set<Int>> {
        self.$popupState.rulesWildcardSelected
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

                } else if (self.rules.count == 1) {

                    self.DomainNameView(
                        text: self.rules.first ?? NOT_APPLICABLE,
                        opacity: self.isActiveRule || self.isEnabledButton ? 1.0 : 0.5
                    )

                } else {

                    ForEach(self.rules.indices, id: \.self) { index in
                        HStack(spacing: 10) {

                            let isChecked = self.selected.wrappedValue.contains(index)

                            self.DomainNameView(
                                text: self.rules[index],
                                opacity: isChecked || self.isEnabledButton ? 1.0 : 0.5
                            )

                            DomainRuleWildcardPanel_Checkbox(
                                selected: self.selected,
                                index: index,
                                color: self.colorDomainName
                            ).disabled(
                                !self.isEnabledButton
                            )

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
                title: NSLocalizedString("allow", comment: ""),
                minWidth: 180,
                onClick: {
                    self.onClickAllow(
                        self.selected.wrappedValue
                    )
                }
            ).disabled(
                !self.isEnabledButton
            )
        }
        .overlayPolyfill(alignment: .leading) {
            if (self.isEnabledButton_byScript) {
                if let domainName = self.popupState.domainName {
                    ScriptsPanel(
                        domainName: domainName,
                        scripts: self.$popupState.scripts,
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

struct DomainRuleWildcardPanel_MatchNone_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) { DomainRuleWildcardPanel().background(Color.popup.rulesWildcardBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.domainName = "example.com"
                PopupState.shared.match = nil
                PopupState.shared.rulesWildcard = []
            }
    }
}

struct DomainRuleWildcardPanel_MatchNoOne_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) { DomainRuleWildcardPanel().background(Color.popup.rulesWildcardBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.domainName = "example.com"
                PopupState.shared.match = .noOne
                PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            }
    }
}

struct DomainRuleWildcardPanel_MatchExact_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) { DomainRuleWildcardPanel().background(Color.popup.rulesWildcardBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.domainName = "example.com"
                PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
                PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            }
    }
}

struct DomainRuleWildcardPanel_MatchWildcard_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 0) { DomainRuleWildcardPanel().background(Color.popup.rulesWildcardBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.domainName = "example.com"
                PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
                PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            }
    }
}
