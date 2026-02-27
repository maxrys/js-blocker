
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRulePanel: View {

    final class State: ObservableObject {
        @Published var selectedCurrent: Set<Int> = []
    }

    @ObservedObject private var state = State()

    static let ICON_CHECK         = Image("checkbox")
    static let ICON_CHECK_CHECKED = Image("checkbox-checked")

    private var colorDomainName: Color {
        if (self.ruleIsActive) { return Color.domainRulePanel.nameActive }
        else                   { return Color.domainRulePanel.name }
    }

    private var colorBorder: Color {
        if (self.ruleIsActive) { return Color.domainRulePanel.borderActive }
        else                   { return Color.domainRulePanel.border }
    }

    private var colorBackground: Color {
        Color.domainRulePanel.background
    }

    private let title: String
    private let rules: [String]
    private let ruleIsActive: Bool
    private let buttonIsEnabled: Bool
    private let buttonTitle: String
    private let selectedDefault: [Int]
    private let buttonOnClick: ([Int]) -> Void

    init(
        title: String = "",
        rules: [String] = [],
        ruleIsActive: Bool,
        buttonIsEnabled: Bool,
        buttonTitle: String = NSLocalizedString("allow", comment: ""),
        selectedDefault: [Int] = [],
        buttonOnClick: @escaping ([Int]) -> Void = { _ in }
    ) {
        self.title = title
        self.rules = rules
        self.ruleIsActive = ruleIsActive
        self.buttonIsEnabled = buttonIsEnabled
        self.buttonTitle = buttonTitle
        self.selectedDefault = selectedDefault
        self.buttonOnClick = buttonOnClick
        self.state.selectedCurrent.removeAll()
        for index in self.selectedDefault {
            self.state.selectedCurrent.insert(index)
        }
    }

    public var body: some View {
        VStack(spacing: 13) {

            /* MARK: Block title */

            Text(self.title)
                .font(.system(size: 14, weight: .bold))

            /* MARK: Domain selector */

            VStack (alignment: .trailing, spacing: 5) {
                if (self.rules.isEmpty) {

                    /* MARK: Domain selector (no choise) */

                    self.DomainName(
                        text: NSLocalizedString("...loading...", comment: ""),
                        opacity: self.buttonIsEnabled || self.ruleIsActive ? 1.0 : 0.5
                    )

                } else if (self.rules.count == 1) {

                    /* MARK: Domain selector (single choise) */

                    self.DomainName(
                        text: self.rules.first!,
                        opacity: self.buttonIsEnabled || self.ruleIsActive ? 1.0 : 0.5
                    )

                } else {

                    /* MARK: Domain selector (multiple choise) */

                    ForEach(self.rules.indices, id: \.self) { index in

                        HStack(spacing: 10) {

                            let isChecked = self.state.selectedCurrent.contains(index)

                            self.DomainName(
                                text: self.rules[index],
                                opacity: (self.buttonIsEnabled) || (self.ruleIsActive && isChecked) ? 1.0 : 0.5
                            )

                            self.DomainCheckbox(
                                index: index,
                                isChecked: isChecked
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

            self.ButtonAllow()

        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func DomainName(text: String, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundPolyfill(self.colorDomainName)
            .opacity(opacity)
    }

    @ViewBuilder private func DomainCheckbox(index: Int, isChecked: Bool) -> some View {
        Button {
            self.state.selectedCurrent.toggle(index)
        } label: {
            let icon = isChecked ?
                Self.ICON_CHECK_CHECKED :
                Self.ICON_CHECK
            icon.foregroundPolyfill(self.colorDomainName)
                .font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .disabled(!self.buttonIsEnabled)
        .pointerStyleLinkPolyfill(
            isEnabled: self.buttonIsEnabled
        )
    }

    @ViewBuilder private func ButtonAllow() -> some View {
        ButtonRound(
            title: self.buttonTitle,
            onClick: {
                self.buttonOnClick(
                    Array(self.state.selectedCurrent)
                )
            }
        ).disabled(
            !self.buttonIsEnabled
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct DomainRulePanel_Previews1: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {

            DomainRulePanel(
                title: NSLocalizedString("JavaScript on the Domain", comment: ""),
                rules: ["example.com"],
                ruleIsActive: false,
                buttonIsEnabled: true,
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

            DomainRulePanel(
                title: NSLocalizedString("JavaScript on the Domain", comment: ""),
                rules: ["example.com"],
                ruleIsActive: true,
                buttonIsEnabled: false,
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

            DomainRulePanel(
                title: NSLocalizedString("JavaScript on the Domain", comment: ""),
                rules: ["example.com"],
                ruleIsActive: false,
                buttonIsEnabled: false,
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

        }.frame(width: Popup.FRAME_WIDTH)
    }
}

struct DomainRulePanel_Previews2: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {

            DomainRulePanel(
                title: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: ""),
                rules: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
                ruleIsActive: false,
                buttonIsEnabled: true,
                selectedDefault: [0],
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

            DomainRulePanel(
                title: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: ""),
                rules: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
                ruleIsActive: true,
                buttonIsEnabled: false,
                selectedDefault: [0],
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

            DomainRulePanel(
                title: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: ""),
                rules: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
                ruleIsActive: false,
                buttonIsEnabled: false,
                selectedDefault: [ ],
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

        }.frame(width: Popup.FRAME_WIDTH)
    }
}
