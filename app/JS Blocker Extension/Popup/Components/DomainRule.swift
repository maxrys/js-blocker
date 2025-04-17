
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct DomainRule: View {

    static let COLORNAME_BACKGROUND    = "color Domain Background"
    static let COLORNAME_BORDER        = "color Domain Border"
    static let COLORNAME_BORDER_ACTIVE = "color Domain Border Active"
    static let COLORNAME_NAME          = "color Domain Name"
    static let COLORNAME_NAME_ACTIVE   = "color Domain Name Active"

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

    var title: String
    var rules: [String] = []
    var ruleIsActive: Bool
    var buttonIsEnabled: Bool
    var buttonTitle: String = "allow"
    var buttonOnClick: () -> Void

    var body: some View {

        VStack(spacing: 13) {

            /* MARK: Title */
            Text(NSLocalizedString(self.title, comment: ""))
                .font(.system(size: 14, weight: .bold))

            /* MARK: Domain name */
            VStack (spacing: 6) {
                if self.rules.count > 0 {
                    ForEach(self.rules, id: \.self) { rule in
                        Text(rule)
                            .font(.system(size: 12, weight: .bold))
                            .color(self.colorDomainName)
                    }
                } else {
                    Text(NSLocalizedString("...loading...", comment: ""))
                        .font(.system(size: 12, weight: .bold))
                        .color(self.colorDomainName)
                }
            }
            .padding(13)
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
                onClick  : self.buttonOnClick
            )

        }
        .padding(20)
        .frame(maxWidth: .infinity)

    }

}

#Preview {
    VStack() {

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["example.com"],
            ruleIsActive: true,
            buttonIsEnabled: true,
            buttonOnClick: {
                print("onClick: DomainRule #1")
            }
        )

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["example.com"],
            ruleIsActive: false,
            buttonIsEnabled: true,
            buttonOnClick: {
                print("onClick: DomainRule #2")
            }
        ).background(Color(Popup.COLORNAME_FOOT_BACKGROUND))

        DomainRule(
            title: "JavaScript on the Domain",
            ruleIsActive: true,
            buttonIsEnabled: false,
            buttonOnClick: {
                print("onClick: DomainRule #3")
            }
        )

        DomainRule(
            title: "JavaScript on the Domain",
            ruleIsActive: false,
            buttonIsEnabled: false,
            buttonOnClick: {
                print("onClick: DomainRule #4")
            }
        ).background(Color(Popup.COLORNAME_FOOT_BACKGROUND))

    }.frame(width: 300, height: 670)
}

#Preview {
    VStack() {

        DomainRule(
            title: "JavaScript on the Domain",
            rules: [],
            ruleIsActive: false,
            buttonIsEnabled: false,
            buttonOnClick: {
                print("onClick: DomainRule #1")
            }
        )

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["example.com"],
            ruleIsActive: true,
            buttonIsEnabled: true,
            buttonOnClick: {
                print("onClick: DomainRule #2")
            }
        ).background(Color(Popup.COLORNAME_FOOT_BACKGROUND))

        DomainRule(
            title: "JavaScript on the Domain",
            rules: ["subdomain.example.com", "example.com"],
            ruleIsActive: true,
            buttonIsEnabled: true,
            buttonOnClick: {
                print("onClick: DomainRule #3")
            }
        )

    }.frame(width: 300, height: 550)
}
