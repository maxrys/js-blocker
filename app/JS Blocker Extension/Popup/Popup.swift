
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    static let COLORNAME_BODY_BACKGROUND = "color Popup Body Background"
    static let COLORNAME_FOOT_BACKGROUND = "color Popup Foot Background"
    static let COLORNAME_BUTTON_CLOUD    = "color Button Cloud"
    static let COLORNAME_BUTTON_SETTINGS = "color Button Settings"

    static let ICON_CLOUD    = Image(systemName: "cloud")
    static let ICON_SETTINGS = Image(systemName: "gearshape.fill")

    static let FRAME_WIDTH: CGFloat = 450

    @Environment(\.openURL) private var openURL
    @ObservedObject var state: PopupState

    var frameWidth: CGFloat = Self.FRAME_WIDTH

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

                ZStack(alignment: .topTrailing) {

                    HStack(spacing: 10) {

                        /* MARK: Indicator "Cloud" */
                        if (App.isCloudEnabled) {
                            Self.ICON_CLOUD
                                .font(.system(size: 20))
                                .color(Color(Self.COLORNAME_BUTTON_CLOUD))
                                .padding(.leading, 3)
                        }

                        Spacer()

                        /* MARK: Button "Settings" */
                        Button {
                            openURL(
                                URL(string: "jsBlocker://")!
                            )
                        } label: {
                            Self.ICON_SETTINGS
                                .font(.system(size: 20))
                                .color(Color(Self.COLORNAME_BUTTON_SETTINGS))
                        }
                        .buttonStyle(.plain)
                        .onHover { isInView in
                            if (isInView) { NSCursor.pointingHand.push() }
                            else          { NSCursor.pop() }
                        }
                        .focusable(false)

                    }.padding(.horizontal, 10)

                    /* MARK: JavaScript on the Domain */
                    DomainRule(
                        title: "JavaScript on the Domain",
                        rules:           self.state.rulesForLocal,
                        ruleIsActive:    self.state.isActiveLocalRule,
                        buttonIsEnabled: self.state.isEnabledLocalRule,
                        selectedDefault: self.state.indecesForLocal,
                        buttonOnClick: { _ in
                            SafariExtensionViewController.shared.onClick_buttonRuleLocalInsert()
                        }
                    )

                }

                /* MARK: JavaScript on the Domain + Subdomains */
                DomainRule(
                    title: "JavaScript on the Domain + Subdomains",
                    rules:           self.state.rulesForGlobal,
                    ruleIsActive:    self.state.isActiveGlobalRule,
                    buttonIsEnabled: self.state.isEnabledGlobalRule,
                    selectedDefault: self.state.indecesForGLobal,
                    buttonOnClick: { indeces in
                        SafariExtensionViewController.shared.onClick_buttonRuleGlobalInsert(
                            indeces: indeces
                        )
                    }
                )

            }
            .padding(.vertical, 11)
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
                        SafariExtensionViewController.shared.onClick_buttonRuleDelete()
                    }
                )

            }
            .padding(31)
            .frame(maxWidth: .infinity)
            .background(Color(Self.COLORNAME_FOOT_BACKGROUND))

        }
        .frame(width: self.frameWidth)
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct PopupState_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {

            Popup(
                state: PopupState(
                    rulesForLocal: ["example.com"],
                    rulesForGlobal: ["*.example.com"],
                    isActiveLocalRule: false,
                    isActiveGlobalRule: false,
                    isEnabledLocalRule: true,
                    isEnabledGlobalRule: true,
                    isEnabledRuleCancel: false
                )
            )

            Popup(
                state: PopupState(
                    rulesForLocal: ["sub3.sub2.sub1.example.com"],
                    rulesForGlobal: ["*.sub3.sub2.sub1.example.com", "*.sub2.sub1.example.com", "*.sub1.example.com", "*.example.com"],
                    isActiveLocalRule: false,
                    isActiveGlobalRule: true,
                    isEnabledLocalRule: false,
                    isEnabledGlobalRule: false,
                    isEnabledRuleCancel: true,
                    indecesForGLobal: [0],
                    messages: [
                        MessageInfo(
                            title: NSLocalizedString("Permission for the following domain was added:", comment: ""),
                            description: ["example.com", "subdomain.example.com"].joined(separator: "\n"),
                            type: .ok
                        )
                    ]
                )
            )

        }
    }
}
