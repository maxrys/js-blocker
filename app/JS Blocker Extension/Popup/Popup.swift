
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    static let COLORNAME_BODY_BACKGROUND = "color Popup Body Background"
    static let COLORNAME_FOOT_BACKGROUND = "color Popup Foot Background"

    @ObservedObject var state: PopupState

    var frameSizeWidth: CGFloat = 450

    var body: some View {
        VStack(spacing: 0) {

            /* ################# */
            /* ### MARK: Message */
            /* ################# */

            ForEach(self.state.messages, id: \.self) { message in
                Message(
                    title      : message.title,
                    description: message.description,
                    type       : message.type
                )
            }

            /* ############## */
            /* ### MARK: Body */
            /* ############## */

            VStack(spacing: 0) {

                /* MARK: JavaScript on the Domain */
                DomainRule(
                    title: "JavaScript on the Domain",
                    rules:           self.state.rulesForLocal,
                    ruleIsActive:    self.state.isActiveLocalRule,
                    buttonIsEnabled: self.state.isEnabledLocalRule,
                    buttonOnClick: {
                        PopupViewController.onClick_buttonRuleInsert()
                    }
                )

                /* MARK: JavaScript on the Domain + Subdomains */
                DomainRule(
                    title: "JavaScript on the Domain + Subdomains",
                    rules:           self.state.rulesForGlobal,
                    ruleIsActive:    self.state.isActiveGlobalRule,
                    buttonIsEnabled: self.state.isEnabledGlobalRule,
                    buttonOnClick: {
                        PopupViewController.onClick_buttonRuleInsertWithSubdomains()
                    }
                )

            }
            .frame(maxWidth: .infinity)
            .background(Color(Self.COLORNAME_BODY_BACKGROUND))

            /* ############## */
            /* ### MARK: Foot */
            /* ############## */

            VStack {

                RoundButton(
                    title: "cancel permission",
                    color: .blue,
                    isEnabled: self.state.isEnabledRuleCancel,
                    minWidth: 250,
                    onClick: {
                        PopupViewController.onClick_buttonRuleDelete()
                    }
                )

            }
            .padding(30)
            .frame(maxWidth: .infinity)
            .background(Color(Self.COLORNAME_FOOT_BACKGROUND))

        }.frame(width: self.frameSizeWidth)
    }
}

#Preview {
    VStack() {

        Popup(
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: true,
                isActiveGlobalRule: true,
                isEnabledLocalRule: true,
                isEnabledGlobalRule: true,
                isEnabledRuleCancel: true,
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
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: false,
                isActiveGlobalRule: false,
                isEnabledLocalRule: false,
                isEnabledGlobalRule: false,
                isEnabledRuleCancel: false,
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
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: true,
                isActiveGlobalRule: false,
                isEnabledLocalRule: false,
                isEnabledGlobalRule: false,
                isEnabledRuleCancel: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: false,
                isActiveGlobalRule: true,
                isEnabledLocalRule: false,
                isEnabledGlobalRule: false,
                isEnabledRuleCancel: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: false,
                isActiveGlobalRule: false,
                isEnabledLocalRule: true,
                isEnabledGlobalRule: false,
                isEnabledRuleCancel: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: false,
                isActiveGlobalRule: false,
                isEnabledLocalRule: false,
                isEnabledGlobalRule: true,
                isEnabledRuleCancel: false
            ),
            frameSizeWidth: 300
        )

        Popup(
            state: PopupState(
                rulesForLocal: ["subdomain.example.com"],
                rulesForGlobal: ["*.example.com"],
                isActiveLocalRule: false,
                isActiveGlobalRule: false,
                isEnabledLocalRule: false,
                isEnabledGlobalRule: false,
                isEnabledRuleCancel: true
            ),
            frameSizeWidth: 300
        )

    }
}
