
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    static let ICON_CLOUD    = Image(systemName: "cloud")
    static let ICON_SETTINGS = Image(systemName: "gearshape.fill")

    static let FRAME_WIDTH: CGFloat = 450

    @Environment(\.openURL) private var openURL
    @ObservedObject private var state: PopupState
    @StateObject private var userDefaultsState = UserDefaultsState.shared

    private let frameWidth: CGFloat
    private let messageBox: MessageBox

    init(state: PopupState, frameWidth: CGFloat = Self.FRAME_WIDTH) {
        self.state = state
        self.frameWidth = frameWidth
        self.messageBox = MessageBox()
    }

    public var body: some View {
        VStack(spacing: 0) {

            /* ################# */
            /* ### MARK: Message */
            /* ################# */

            self.messageBox

            /* ############## */
            /* ### MARK: Body */
            /* ############## */

            VStack(spacing: 0) {

                /* MARK: JavaScript on the Domain */

                DomainRulePanel(
                    title: NSLocalizedString("JavaScript on the Domain", comment: ""),
                    rules:           self.state.rulesForLocal,
                    ruleIsActive:    self.state.isActiveLocalRule,
                    buttonIsEnabled: self.state.isEnabledLocalRule,
                    selectedDefault: self.state.indecesForLocal,
                    buttonOnClick: { _ in
                        ExtensionController.shared.onClick_buttonRuleLocalInsert()
                    }
                )

                /* MARK: JavaScript on the Domain + Subdomains */

                DomainRulePanel(
                    title: NSLocalizedString("JavaScript on the Domain + Subdomains", comment: ""),
                    rules:           self.state.rulesForGlobal,
                    ruleIsActive:    self.state.isActiveGlobalRule,
                    buttonIsEnabled: self.state.isEnabledGlobalRule,
                    selectedDefault: self.state.indecesForGLobal,
                    buttonOnClick: { indeces in
                        ExtensionController.shared.onClick_buttonRuleGlobalInsert(
                            indeces: indeces
                        )
                    }
                )

            }
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(Color.popup.bodyBackground)

            /* MARK: Indicator "Cloud" */

            .overlayPolyfill(alignment: .topLeading) {
                if (self.userDefaultsState.icloudStatus) {
                    self.CloudIndicator()
                }
            }

            /* MARK: Button "Settings" */

            .overlayPolyfill(alignment: .topTrailing) {
                self.ButtonSettings()
            }

            /* ############## */
            /* ### MARK: Foot */
            /* ############## */

            self.ButtonCancelPermission()
                .padding(31)
                .frame(maxWidth: .infinity)
                .background(Color.popup.footBackground)

        }
        .frame(width: self.frameWidth)
        .environment(\.layoutDirection, .leftToRight)
    }

    @ViewBuilder private func CloudIndicator() -> some View {
        Self.ICON_CLOUD
            .font(.system(size: 20))
            .foregroundPolyfill(Color.popup.buttonCloud)
            .padding(10)
    }

    @ViewBuilder private func ButtonSettings() -> some View {
        Button {
            openURL(
                URL(string: "jsBlocker://")!
            )
        } label: {
            Self.ICON_SETTINGS
                .font(.system(size: 20))
                .foregroundPolyfill(Color.popup.buttonSettings)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
        .focusable(false)
        .padding(10)
    }

    @ViewBuilder private func ButtonCancelPermission() -> some View {
        ButtonRound(
            title: NSLocalizedString("cancel permission", comment: ""),
            color: .blue,
            minWidth: 250,
            onClick: {
                ExtensionController.shared.onClick_buttonRuleDelete()
            }
        ).disabled(
            !self.state.isEnabledRuleCancel
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct Popup_Previews: PreviewProvider {
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

        }.onAppear {
            MessageBox.insert(
                type: .ok,
                title: NSLocalizedString("Permission for the following domain was added:", comment: ""),
                description: "example.com",
                lifeTime: .infinity
            )
        }
    }
}
