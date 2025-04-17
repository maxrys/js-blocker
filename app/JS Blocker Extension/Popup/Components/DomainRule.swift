
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRule: View {

    class State: ObservableObject {
        @Published var selectedCurrent: [Int: Bool] = [:]
    }

    static let COLORNAME_BACKGROUND    = "color Domain Background"
    static let COLORNAME_BORDER        = "color Domain Border"
    static let COLORNAME_BORDER_ACTIVE = "color Domain Border Active"
    static let COLORNAME_NAME          = "color Domain Name"
    static let COLORNAME_NAME_ACTIVE   = "color Domain Name Active"

    static let ICON_CHECK         = Image(systemName: "square")
    static let ICON_CHECK_CHECKED = Image(systemName: "square.inset.filled")

    var colorDomainName: Color {
        if (self.ruleIsActive) { return Color(Self.COLORNAME_NAME_ACTIVE) }
        else                   { return Color(Self.COLORNAME_NAME) }
    }

    var colorBackground: Color {
        if (self.ruleIsActive) { return Color(Self.COLORNAME_BACKGROUND) }
        else                   { return Color(Self.COLORNAME_BACKGROUND) }
    }

    var colorBorder: Color {
        if (self.ruleIsActive) { return Color(Self.COLORNAME_BORDER_ACTIVE) }
        else                   { return Color(Self.COLORNAME_BORDER) }
    }

    @ObservedObject var state = State()

    var title: String
    var rules: [String] = []
    var ruleIsActive: Bool
    var buttonIsEnabled: Bool
    var buttonTitle: String
    var selectedDefault: [Int] = []
    var buttonOnClick: ([Int]) -> Void

    init(title: String = "", rules: [String] = [], ruleIsActive: Bool, buttonIsEnabled: Bool, buttonTitle: String = "allow", selectedDefault: [Int] = [], buttonOnClick: @escaping ([Int]) -> Void = { _ in }) {
        self.title = title
        self.rules = rules
        self.ruleIsActive = ruleIsActive
        self.buttonIsEnabled = buttonIsEnabled
        self.buttonTitle = buttonTitle
        self.selectedDefault = selectedDefault
        self.buttonOnClick = buttonOnClick
        self.state.selectedCurrent = [:]
        for index in self.selectedDefault {
            self.state.selectedCurrent[index] = true
        }
    }

    var body: some View {

        VStack(spacing: 13) {

            /* MARK: Block title */
            Text(NSLocalizedString(self.title, comment: ""))
                .font(.system(size: 14, weight: .bold))

            /* MARK: Domain selector */
            VStack (alignment: .trailing, spacing: 5) {
                if (self.rules.isEmpty) {

                    /* MARK: Domain selector (no choise) */
                    Text(NSLocalizedString("...loading...", comment: ""))
                        .font(.system(size: 12, weight: .bold))
                        .color(self.colorDomainName)
                        .opacity(
                            self.buttonIsEnabled || self.ruleIsActive ? 1.0 : 0.5
                        )

                } else if (self.rules.count == 1) {

                    /* MARK: Domain selector (single choise) */
                    Text(self.rules.first!)
                        .font(.system(size: 12, weight: .bold))
                        .color(self.colorDomainName)
                        .opacity(
                            self.buttonIsEnabled || self.ruleIsActive ? 1.0 : 0.5
                        )

                } else {

                    /* MARK: Domain selector (multiple choise) */
                    ForEach(self.rules.indices, id: \.self) { index in

                        HStack(spacing: 10) {

                            let isChecked = self.state.selectedCurrent[
                                index,
                                default: false
                            ]

                            /* MARK: Domain name */
                            Text(self.rules[index])
                                .font(.system(size: 12, weight: .bold))
                                .color(self.colorDomainName)
                                .opacity(
                                    (self.buttonIsEnabled) || (self.ruleIsActive && isChecked) ? 1.0 : 0.5
                                )

                            /* MARK: Checkbox */
                            Button {
                                self.state.selectedCurrent[
                                    index, default: false
                                ].toggle()
                            } label: {
                                let icon = isChecked ?
                                    Self.ICON_CHECK_CHECKED :
                                    Self.ICON_CHECK
                                icon.color(self.colorDomainName)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(.plain)
                            .disabled(!self.buttonIsEnabled)
                            .onHover { isInView in
                                if (self.buttonIsEnabled) {
                                    if (isInView) { NSCursor.pointingHand.push() }
                                    else          { NSCursor.pop() }
                                }   else          { NSCursor.pop() }
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
                   .clipShape(.rect(cornerRadius: 12))
            )

            /* MARK: Button "allow" */
            RoundButton(
                title    : self.buttonTitle,
                isEnabled: self.buttonIsEnabled,
                onClick  : {
                    self.buttonOnClick(
                        self.state.selectedCurrent.compactMap({ (key, value) in
                            value ? key : nil
                        })
                    )
                }
            )

        }
        .padding(20)
        .frame(maxWidth: .infinity)

    }

}

#Preview {
    VStack(spacing: 0) {

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["example.com"],
            ruleIsActive: false,
            buttonIsEnabled: true,
            buttonOnClick: { index in }
        ).background(Color(Popup.COLORNAME_BODY_BACKGROUND))

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["example.com"],
            ruleIsActive: true,
            buttonIsEnabled: false,
            buttonOnClick: { index in }
        ).background(Color(Popup.COLORNAME_FOOT_BACKGROUND))

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["example.com"],
            ruleIsActive: false,
            buttonIsEnabled: false,
            buttonOnClick: { index in }
        ).background(Color(Popup.COLORNAME_BODY_BACKGROUND))

    }.frame(width: Popup.FRAME_WIDTH)
}


#Preview {
    VStack(spacing: 0) {

        DomainRule(
            title: "JavaScript on the Domain + Subdomains",
            rules: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
            ruleIsActive: false,
            buttonIsEnabled: true,
            selectedDefault: [0],
            buttonOnClick: { index in }
        ).background(Color(Popup.COLORNAME_BODY_BACKGROUND))

        DomainRule(
            title: "JavaScript on the Domain + Subdomains",
            rules: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
            ruleIsActive: true,
            buttonIsEnabled: false,
            selectedDefault: [0],
            buttonOnClick: { index in }
        ).background(Color(Popup.COLORNAME_FOOT_BACKGROUND))

        DomainRule(
            title: "JavaScript on the Domain + Subdomains",
            rules: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
            ruleIsActive: false,
            buttonIsEnabled: false,
            selectedDefault: [ ],
            buttonOnClick: { index in }
        ).background(Color(Popup.COLORNAME_BODY_BACKGROUND))

    }.frame(width: Popup.FRAME_WIDTH)
}
