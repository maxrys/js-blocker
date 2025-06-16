
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    enum ColorNames: String {
        case bodyBackground = "color Popup Body Background"
        case footBackground = "color Popup Foot Background"
        case buttonCloud    = "color Button Cloud"
        case buttonSettings = "color Button Settings"
    }

    static let ICON_CLOUD    = Image(systemName: "cloud")
    static let ICON_SETTINGS = Image(systemName: "gearshape.fill")

    static let FRAME_WIDTH: CGFloat = 450

    @Environment(\.openURL) private var openURL
    @ObservedObject var state: PopupState

    var frameWidth: CGFloat = Self.FRAME_WIDTH

    static let EVENT_NAME_FOR_POPUP_SIZE_CHANGE = "PopupSizeChange"
    private let publisherForSizeChange = EventsDispatcher.shared.publisher(
        Self.EVENT_NAME_FOR_POPUP_SIZE_CHANGE
    )!

    var body: some View {
        VStack(spacing: 0) {

            /* ################# */
            /* ### MARK: Message */
            /* ################# */

            MessageBox()

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
                                .color(Color(Self.ColorNames.buttonCloud.rawValue))
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
                                .color(Color(Self.ColorNames.buttonSettings.rawValue))
                        }
                        .buttonStyle(.plain)
                        .onHoverCursor()
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
            .background(Color(Self.ColorNames.bodyBackground.rawValue))

            /* ############## */
            /* ### MARK: Foot */
            /* ############## */

            VStack {

                RoundButton(
                    title: "cancel permission",
                    color: .blue,
                    minWidth: 250,
                    onClick: {
                        SafariExtensionViewController.shared.onClick_buttonRuleDelete()
                    }
                ).disabled(
                    !self.state.isEnabledRuleCancel
                )

            }
            .padding(31)
            .frame(maxWidth: .infinity)
            .background(Color(Self.ColorNames.footBackground.rawValue))

        }
        .frame(width: self.frameWidth)
        .environment(\.layoutDirection, .leftToRight)
        .onGeometryChange(for: CGSize.self) { geometryProxy in geometryProxy.size } action: { size in
            EventsDispatcher.shared.send(
                Self.EVENT_NAME_FOR_POPUP_SIZE_CHANGE,
                object: size
            )
        }
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
                    indecesForGLobal: [0]
                )
            )

        }
    }
}
