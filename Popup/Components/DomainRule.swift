
import SwiftUI

struct DomainRule: View {

    var colorDomainName: Color {
        if self.ruleIsActive {return Color(ENV.COLORNAME_DOMAIN_NAME_ACTIVE)}
        else                 {return Color(ENV.COLORNAME_DOMAIN_NAME)}
    }

    var colorBackground: Color {
        if self.ruleIsActive {return Color(ENV.COLORNAME_DOMAIN_BACKGROUND)}
        else                 {return Color(ENV.COLORNAME_DOMAIN_BACKGROUND)}
    }

    var colorBorder: Color {
        if self.ruleIsActive {return Color(ENV.COLORNAME_DOMAIN_BORDER_ACTIVE)}
        else                 {return Color(ENV.COLORNAME_DOMAIN_BORDER)}
    }

    var title: String
    var rule: String?
    var ruleIsActive: Bool
    var buttonIsEnabled: Bool
    var buttonTitle: String = "allow"
    var buttonOnClick: () -> Void

    var body: some View {

        VStack(spacing: 13) {

            // Title
            Text(NSLocalizedString(self.title, comment: ""))
                .font(.system(size: 14, weight: .bold))

            // Domain name
            VStack {
                Text(self.rule ?? NSLocalizedString("...loading...", comment: ""))
                    .font(.system(size: 12, weight: .bold))
                    .color(self.colorDomainName)
            }.padding(13)
             .frame(maxWidth: .infinity)
             .background(self.colorBackground)
             .cornerRadius(12) // make the background rounded
             .overlay( // apply a rounded border
                 RoundedRectangle(cornerRadius: 12)
                    .stroke(self.colorBorder, lineWidth: 2)
             )

            // Button "allow"
            RoundButton(
                title    : self.buttonTitle,
                isEnabled: self.buttonIsEnabled,
                onClick  : self.buttonOnClick
            )

        }.padding(20)
         .frame(maxWidth: .infinity)

    }

}

#Preview {
    VStack() {

        DomainRule(
            title: "JavaScript on the Domain",
            rule: "example.com",
            ruleIsActive: true,
            buttonIsEnabled: true,
            buttonOnClick: {
                print("onClick: DomainRule #1")
            }
        )

        DomainRule(
            title: "JavaScript on the Domain",
            rule: "example.com",
            ruleIsActive: false,
            buttonIsEnabled: true,
            buttonOnClick: {
                print("onClick: DomainRule #2")
            }
        ).background(Color(ENV.COLORNAME_PAGE_FOOT_BACKGROUND))

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
        ).background(Color(ENV.COLORNAME_PAGE_FOOT_BACKGROUND))

    }.frame(width: 450, height: 670)
}
