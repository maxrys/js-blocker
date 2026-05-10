
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRulePanel: View {

    static let ICON_CHECK         = Image("checkbox")
    static let ICON_CHECK_CHECKED = Image("checkbox-checked")

    @ObservedObject private var selectedCurrent: ValueState<Set<Int>>

    private var colorDomainName: Color {
        if (self.ruleIsActive && !self.rules.isEmpty)
             { return Color.domainRulePanel.nameActive }
        else { return Color.domainRulePanel.name }
    }

    private var colorBorder: Color {
        if (self.ruleIsActive && !self.rules.isEmpty)
             { return Color.domainRulePanel.borderActive }
        else { return Color.domainRulePanel.border }
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
        self.selectedCurrent = ValueState<Set<Int>>(
            Set(selectedDefault)
        )
    }

    public var body: some View {
        VStack(spacing: 13) {

            /* MARK: Title */

            Text(self.title)
                .font(.system(size: 14, weight: .bold))

            /* MARK: Domain selector */

            VStack (alignment: .trailing, spacing: 5) {
                if (self.rules.isEmpty) {

                    self.DomainName(
                        text: NSLocalizedString("...loading...", comment: ""),
                        opacity: 0.5
                    )

                } else if (self.rules.count == 1) {

                    self.DomainName(
                        text: self.rules.first!,
                        opacity:
                            self.ruleIsActive ||
                            self.buttonIsEnabled ? 1.0 : 0.5
                    )

                } else {

                    ForEach(self.rules.indices, id: \.self) { index in
                        HStack(spacing: 10) {

                            let isChecked = self.selectedCurrent.value.contains(index)

                            self.DomainName(
                                text: self.rules[index],
                                opacity: isChecked || self.buttonIsEnabled ? 1.0 : 0.5
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
                .disabled(
                    !self.buttonIsEnabled || self.rules.isEmpty
                )

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
            self.selectedCurrent.value.toggle(index)
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
            self.buttonIsEnabled
        )
    }

    @ViewBuilder private func ButtonAllow() -> some View {
        ButtonRound(
            title: self.buttonTitle,
            onClick: {
                self.buttonOnClick(
                    self.rules.count == 1 ? [0] : Array(self.selectedCurrent.value)
                )
            }
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct DomainRulePanel_None_Previews: PreviewProvider {
    static let title = NSLocalizedString("JavaScript on the Domain", comment: "")
    static let rules: [String] = []
    static var previews: some View {
        VStack(spacing: 0) {

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: false,
                buttonIsEnabled: false,
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: false,
                buttonIsEnabled: true,
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: true,
                buttonIsEnabled: false,
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

        }.frame(width: Popup.FRAME_WIDTH)
    }
}

struct DomainRulePanel_Single_Previews: PreviewProvider {
    static let title = NSLocalizedString("JavaScript on the Domain", comment: "")
    static let rules = ["example.com"]
    static var previews: some View {
        VStack(spacing: 0) {

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: false,
                buttonIsEnabled: false,
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: false,
                buttonIsEnabled: true,
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: true,
                buttonIsEnabled: false,
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

        }.frame(width: Popup.FRAME_WIDTH)
    }
}

struct DomainRulePanel_Multi_Previews: PreviewProvider {
    static let title = NSLocalizedString("JavaScript on the Domain + Subdomains", comment: "")
    static let rules = [
        "*.sub3.sub2.sub1.example.com",
             "*.sub2.sub1.example.com",
                  "*.sub1.example.com",
                       "*.example.com"
    ]
    static var previews: some View {
        VStack(spacing: 0) {

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: false,
                buttonIsEnabled: false,
                selectedDefault: [ ],
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: false,
                buttonIsEnabled: true,
                selectedDefault: [],
                buttonOnClick: { index in }
            ).background(Color.popup.bodyBackground)

            DomainRulePanel(
                title: Self.title,
                rules: Self.rules,
                ruleIsActive: true,
                buttonIsEnabled: false,
                selectedDefault: [0, 2],
                buttonOnClick: { index in }
            ).background(Color.popup.footBackground)

        }.frame(width: Popup.FRAME_WIDTH)
    }
}
