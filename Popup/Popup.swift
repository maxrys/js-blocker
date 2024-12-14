
import SafariServices
import SwiftUI

class PopupStateModel: ObservableObject {

    @Published var ruleForDomain: String?
    @Published var ruleForParent: String?
    @Published var ruleForDomain_isActive: Bool
    @Published var ruleForParent_isActive: Bool
    @Published var ruleForDomain_isEnabled: Bool
    @Published var ruleForParent_isEnabled: Bool
    @Published var ruleCancel_isEnabled: Bool
    @Published var messages: [MessageInfo]

    init(ruleForDomain: String?, ruleForParent: String?, ruleForDomain_isActive: Bool, ruleForParent_isActive: Bool, ruleForDomain_isEnabled: Bool, ruleForParent_isEnabled: Bool, ruleCancel_isEnabled: Bool, messages: [MessageInfo] = []) {
        self.ruleForDomain           = ruleForDomain
        self.ruleForParent           = ruleForParent
        self.ruleForDomain_isActive  = ruleForDomain_isActive
        self.ruleForParent_isActive  = ruleForParent_isActive
        self.ruleForDomain_isEnabled = ruleForDomain_isEnabled
        self.ruleForParent_isEnabled = ruleForParent_isEnabled
        self.ruleCancel_isEnabled    = ruleCancel_isEnabled
        self.messages                = messages
    }

}

struct Popup: View {

    @ObservedObject var stateModel: PopupStateModel

    var frameSizeWidth: CGFloat = 450

    var body: some View {
        VStack(spacing: 0) {

            // ###############
            // ### Message ###
            // ###############

            ForEach(self.stateModel.messages, id: \.self) { message in
                Message(
                    title      : message.title,
                    description: message.description,
                    type       : message.type
                )
            }

            // ############
            // ### Body ###
            // ############

            VStack(spacing: 0) {

                // JavaScript on the Domain
                DomainRule(
                    title: "JavaScript on the Domain",
                    rules:           self.stateModel.ruleForDomain != nil ? [self.stateModel.ruleForDomain!] : [],
                    ruleIsActive:    self.stateModel.ruleForDomain_isActive,
                    buttonIsEnabled: self.stateModel.ruleForDomain_isEnabled,
                    buttonOnClick: {
                        PopupViewController.onClick_buttonRuleInsert()
                    }
                )

                // JavaScript on the Domain + Subdomains
                DomainRule(
                    title: "JavaScript on the Domain + Subdomains",
                    rules:           self.stateModel.ruleForParent != nil ? [self.stateModel.ruleForParent!] : [],
                    ruleIsActive:    self.stateModel.ruleForParent_isActive,
                    buttonIsEnabled: self.stateModel.ruleForParent_isEnabled,
                    buttonOnClick: {
                        PopupViewController.onClick_buttonRuleInsertWithSubdomains()
                    }
                )

            }.frame(maxWidth: .infinity)
             .background(Color(ENV.COLORNAME_PAGE_BODY_BACKGROUND))

            // ############
            // ### Foot ###
            // ############

            VStack {

                RoundButton(
                    title: "cancel permission",
                    color: .blue,
                    isEnabled: self.stateModel.ruleCancel_isEnabled,
                    minWidth: 250,
                    onClick: {
                        PopupViewController.onClick_buttonRuleDelete()
                    }
                )

            }.padding(30)
             .frame(maxWidth: .infinity)
             .background(Color(ENV.COLORNAME_PAGE_FOOT_BACKGROUND))

        }.frame(width: self.frameSizeWidth)
    }
}

#Preview {
    VStack() {

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: true,
                ruleForParent_isActive: true,
                ruleForDomain_isEnabled: true,
                ruleForParent_isEnabled: true,
                ruleCancel_isEnabled: true,
                messages: [
                    MessageInfo(
                        title: "Title",
                        description: "Description",
                        type: .ok
                    )
                ]
            ),
            frameSizeWidth: 300
        )

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: false,
                ruleForParent_isActive: false,
                ruleForDomain_isEnabled: false,
                ruleForParent_isEnabled: false,
                ruleCancel_isEnabled: false,
                messages: [
                    MessageInfo(
                        title: "Title",
                        description: "Description",
                        type: .error
                    )
                ]
            ),
            frameSizeWidth: 300
        )

    }
}

#Preview {
    VStack(spacing: 50) {

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: true,
                ruleForParent_isActive: false,
                ruleForDomain_isEnabled: false,
                ruleForParent_isEnabled: false,
                ruleCancel_isEnabled: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: false,
                ruleForParent_isActive: true,
                ruleForDomain_isEnabled: false,
                ruleForParent_isEnabled: false,
                ruleCancel_isEnabled: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: false,
                ruleForParent_isActive: false,
                ruleForDomain_isEnabled: true,
                ruleForParent_isEnabled: false,
                ruleCancel_isEnabled: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: false,
                ruleForParent_isActive: false,
                ruleForDomain_isEnabled: false,
                ruleForParent_isEnabled: true,
                ruleCancel_isEnabled: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            stateModel: PopupStateModel(
                ruleForDomain: "subdomain.example.com",
                ruleForParent: "*.example.com",
                ruleForDomain_isActive: false,
                ruleForParent_isActive: false,
                ruleForDomain_isEnabled: false,
                ruleForParent_isEnabled: false,
                ruleCancel_isEnabled: true
            ),
            frameSizeWidth: 300
        )

    }
}
