
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices
import SwiftUI

struct Popup: View {

    static let ICON_SETTINGS = Image(systemName: "gearshape.fill")
    static let FRAME_WIDTH: CGFloat = 450

    static let messageBoxAddress: MessageBoxAddress = .local(boxID: MessageBoxID(1))
    static let messageIDForCurrentOperation: MessageID = 0

    @Environment(\.openURL) private var openURL

    @StateObject private var userDefaultsState = UserDefaultsState.shared
    @StateObject private var popupState        = PopupState.shared

    @State private var mainViewSize: CGSize = .zero

    private var colorRuleExactBackground: Color {
        Color.popup.ruleExactBackground
            .opacity(0.9)
    }

    private var colorRuleWildcarBackground: Color {
        Color.popup.rulesWildcardBackground
            .opacity(0.9)
    }

    private var colorRuleCancelBackground: Color {
        Color.popup.ruleCancelBackground
            .opacity(0.9)
    }

    private var colorScriptsBackground: Color {
        switch self.popupState.match {
            case .exactScript   : Color.popup.ruleExactBackground.opacity(0.9)
            case .wildcardScript: Color.popup.rulesWildcardBackground.opacity(0.9)
            default             : Color.scriptsPanel.defaultBackground.opacity(0.9)
        }
    }

    private let frameWidth: CGFloat
    private let messageBox: MessageBox

    init(frameWidth: CGFloat = Self.FRAME_WIDTH) {
        self.frameWidth = frameWidth
        self.messageBox = MessageBox(
            address: Self.messageBoxAddress
        )
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            self.MainView()
                .onGeometryChangePolyfill(
                    type: .inside,
                    size: self.$mainViewSize
                )
            if (self.popupState.match?.isSomeScript == true) {
                ScriptsPanel()
                    .background(
                        self.colorScriptsBackground
                    )
                    .frame(
                        width: ScriptsPanel.FRAME_WIDTH,
                        height: self.mainViewSize.height
                    ).overlayPolyfill(alignment: .leading) {
                        ShadowLine(
                            length: 15,
                            angle: .`270_degrees`,
                            opacity: 0.15,
                            opacityDark: 0.2
                        ).frame(height: self.mainViewSize.height)
                    }
            }
        }.environment(\.layoutDirection, .leftToRight)
    }

    @ViewBuilder private func MainView() -> some View {
        VStack(spacing: 0) {

            self.messageBox

            DomainRuleExactPanel(
                onClickAllow: {
                    ViewController.shared.onClick_ruleExactInsert()
                }
            ).background(
                self.colorRuleExactBackground
            )

            .overlayPolyfill(alignment: .topLeading) {
                HStack(spacing: 5) { /* MARK: Extra Buttons */
                    self.ButtonSettingsView()
                }.padding(10)
            }

            DomainRuleWildcardPanel(
                onClickAllow: { selected in
                    ViewController.shared.onClick_ruleWildcardInsert(selected: selected)
                }
            ).background(
                self.colorRuleWildcarBackground
            )

            self.ButtonCancelRuleView()
                .padding(31)
                .frame(maxWidth: .infinity)
                .background(
                    self.colorRuleCancelBackground
                )

        }.frame(width: self.frameWidth)
    }

    @ViewBuilder private func ButtonSettingsView() -> some View {
        Button {
            openURL(
                URL(string: "\(APP_ID)://")!
            )
        } label: {
            Self.ICON_SETTINGS
                .font(.system(size: 20))
                .foregroundPolyfill(Color.popup.buttonSettings)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
        .focusable(false)
    }

    @ViewBuilder private func ButtonCancelRuleView() -> some View {
        ButtonCapsule(
            title: NSLocalizedString("cancel rule", comment: ""),
            style: .blue,
            minWidth: 250,
            onClick: {
                ViewController.shared.onClick_ruleDelete()
            }
        ).disabled(
            self.popupState.match.ifNil(defaultValue: true) { match in
                !match.isSome
            }
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct Popup_Previews: PreviewProvider {

    struct ViewWithState: View {

        @ObservedObject static private var match = ValueState<UInt>(0) { value in
            switch value {
                case 0:
                    PopupState.shared.match = nil
                    PopupState.shared.domain = nil
                    PopupState.shared.ruleExact = ""
                    PopupState.shared.rulesWildcard = []
                    MessageBox.delete(address: Popup.messageBoxAddress,
                        Popup.messageIDForCurrentOperation
                    )
                case 1:
                    PopupState.shared.match = .noOne
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Exact rule for the following domain was removed:", comment: ""),
                        description: "example.com"
                    ))
                case 2:
                    PopupState.shared.match = .noOneScript
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                    PopupState.shared.scriptsIsOn = ScriptsPanel_PreviewContentGenerator.scriptsIsOn
                    PopupState.shared.scripts = ScriptsPanel_PreviewContentGenerator.generateScripts(count: 10)
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Exact rule for the following domain was removed:", comment: ""),
                        description: "example.com"
                    ))
                case 3:
                    PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                        description: "example.com"
                    ))
                case 4:
                    PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                        description: ["*.example.com"].joined(separator: "\n")
                    ))
                case 5:
                    PopupState.shared.match = .noOne
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__SUBDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__SUBDOMAIN
                    PopupState.shared.rulesWildcardSelected = []
                    PopupState.shared.rulesWildcardDisabled = [2, 3]
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Wildcard rule for the following domain was removed:", comment: ""),
                        description: "example.com"
                    ))
                case 6:
                    PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__SUBDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__SUBDOMAIN
                    PopupState.shared.rulesWildcardSelected = []
                    PopupState.shared.rulesWildcardDisabled = []
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Exact rule for the following domain was added:", comment: ""),
                        description: "sub3.sub2.sub1.example.com"
                    ))
                case 7:
                    PopupState.shared.match = .wildcard(item: DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT)
                    PopupState.shared.domain = DEMO_RULE__TOPDOMAIN
                    PopupState.shared.ruleExact = DEMO_RULE__SUBDOMAIN
                    PopupState.shared.rulesWildcard = DEMO_RULES__SUBDOMAIN
                    PopupState.shared.rulesWildcardSelected = [0, 2]
                    PopupState.shared.rulesWildcardDisabled = []
                    MessageBox.insert(address: Popup.messageBoxAddress, .init(
                        ID: Popup.messageIDForCurrentOperation,
                        type: .ok,
                        lifetime: .infinity,
                        title: NSLocalizedString("Wildcard rules for the following domains were added:", comment: ""),
                        description: ["*.sub3.sub2.sub1.example.com", "*.sub1.example.com"].joined(separator: "\n")
                    ))
                default: break
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                Popup()
                Spacer().frame(minHeight: 0)
                PreviewMode(
                    title: "match",
                    state: Self.match,
                    modes: [
                        "nil", "noOne", "noOneScript", "exact", "wildcard", "N*", "E*", "W*"
                    ]
                )
            }.frame(
                height: 720
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
