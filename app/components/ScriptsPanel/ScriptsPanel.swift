
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ScriptsPanel: View {

    static let ICON_OPENER  = Image("symbol Icon Scripts")

    @StateObject private var popupState = PopupState.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isOpened = false

    private var colorOpenerIcon: Color {
        if (self.isActive)
             { return Color.scriptsPanel.openerIconActive }
        else { return Color.scriptsPanel.openerIcon }
    }

    private var colorOpenerBorder: Color {
        if (self.isActive)
             { return Color.scriptsPanel.openerBorderActive }
        else { return Color.scriptsPanel.openerBorder }
    }

    private var colorOpenerBackground: Color {
        Color.scriptsPanel.openerBackground
    }

    private var scripts: [FrameDomainName: [URLString]] {
        if let domain = self.popupState.domain {
            return self.popupState.scripts[domain] ?? [:]
        } else { return [:] }
    }

    private var hasScripts: Bool {
        !self.scripts.values.allSatisfy(\.isEmpty)
    }

    private var totalCount: Int {
        self.scripts.values.reduce(0) { total, scripts in
            total + scripts.count
        }
    }

    private var isActive: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOneScript || match.isExactScript || match.isWildcardScript
        }
    }

    private var isVisibleFrames: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isNoOneScript
        }
    }

    private var sortedDomains: [FrameDomainName] {
        let domainDecoded = self.popupState.domain?.decodePunycode()
        return self.scripts.keys.sorted(by: { (lhs, rhs) in
            let lhsDecoded = lhs.decodePunycode()
            let rhsDecoded = rhs.decodePunycode()
            if (lhsDecoded == domainDecoded) { return true  } /* current domain always at top */
            if (rhsDecoded == domainDecoded) { return false } /* current domain always at top */
            return lhsDecoded < rhsDecoded /* alphabetical order */
        })
    }

    public var body: some View {
        self.OpenerView()
            .popover(
                isPresented: self.isEnabled ? self.$isOpened : .constant(false),
                arrowEdge: .trailing
            ) {
                self.PopupView()
            }
    }

    @ViewBuilder private func OpenerView() -> some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        Button {
            self.isOpened.toggle()
        } label: {
            shape
                .stroke(self.colorOpenerBorder, lineWidth: 2)
                .background(shape.fill(self.colorOpenerBackground))
                .frame(width: 36, height: 36)
                .overlayPolyfill {
                    Self.ICON_OPENER
                        .font(.system(size: 24))
                }
            .foregroundPolyfill(self.colorOpenerIcon)
            .contentShape(shape)
            .focusEffect (shape)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill(self.isEnabled)
        .disabled(!self.isEnabled)
    }

    @ViewBuilder private func PopupView() -> some View {
        VStack(spacing: 0) {

            self.PopupHead_TitleView()

            if (self.isVisibleFrames) {
                self.PopupSriptsModeToggleView()
            }

            if (self.isActive) {
                Group {
                    if (self.totalCount < 20) { self.PopupBodyView() }
                    else         { ScrollView { self.PopupBodyView() }.frame(height: 600) }
                }
                .overlayPolyfill(alignment: .top) {
                    self.PopupHead_ShadowView(height: 5)
                }
                .overlayPolyfill(alignment: .topTrailing) {
                    RefreshButton(onClick: self.popupState.jsGetScripts)
                        .foregroundPolyfill(Color.scriptsPanel.popupTitle)
                        .offset(x: -30, y: -45)
                }
            }

        }.frame(width: 600)
    }

    @ViewBuilder private func PopupHead_TitleView() -> some View {
        Text(NSLocalizedString("Scripts", comment: ""))
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(15)
            .foregroundPolyfill(Color.scriptsPanel.popupTitle)
            .background(Color.scriptsPanel.popupTitleBackground)
    }

    @ViewBuilder private func PopupHead_ShadowView(height: CGFloat = 5) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.scriptsPanel.popupTitleBorder)
                .frame(height: 1)
            ShadowLine(
                length: height,
                opacity: 0.3,
                opacityDark: 0.5
            )
        }
    }

    @ViewBuilder private func PopupSriptsModeToggleView(height: CGFloat = 5) -> some View {
        ToggleCustom(
            text: NSLocalizedString("Allow JS separately by script", comment: ""),
            isOn: Binding(
                get: { self.popupState.match?.isNoOneScript ?? false },
                set: { _ in
                    if case .noOne       = self.popupState.match { Task { @MainActor in self.popupState.match = .noOneScript } }
                    if case .noOneScript = self.popupState.match { Task { @MainActor in self.popupState.match = .noOne } }
                }
            ),
            size: CGSize(width: 50, height: 20),
            font: .system(size: 18)
        )
        .padding(.init(top: 23, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: .infinity)
        .background(
            self.colorScheme == .dark ?
                Color.white.opacity(0.1) :
                Color.white.opacity(0.3)
        )
    }

    @ViewBuilder private func PopupBodyView() -> some View {
        if (self.hasScripts) {
            VStack(spacing: 10) {
                ForEach(self.sortedDomains, id: \.self) { frameDomain in
                    self.PopupBody_FrameScriptsView(
                        frameDomain: frameDomain,
                        frameScripts: self.scripts[
                            frameDomain
                        ] ?? []
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        } else {
            Text(NSLocalizedString("no strips", comment: ""))
                .multilineTextAlignment(.center)
                .padding(30)
        }
    }

    @ViewBuilder private func PopupBody_FrameScriptsView(
        frameDomain: FrameDomainName,
        frameScripts: [URLString]
    ) -> some View {
        VStack(spacing: 0) {
            if let domain = self.popupState.domain {

                if (domain != frameDomain) {

                    HStack(spacing: 10) {
                        Text(NSLocalizedString("Frame with domain:", comment: ""))
                            .font(.headline)
                            .opacity(0.5)
                        Text(frameDomain.decodePunycode())
                            .font(.headline)
                    }.padding(.bottom, 10)

                    Rectangle()
                        .fill(
                            self.colorScheme == .dark ?
                                .white.opacity(0.5) :
                                .black.opacity(0.5)
                        ).frame(height: 1)
                }

                let frameScriptsSorted = frameScripts.sorted(by: { (lhs, rhs) in
                    if (lhs == URL_INTERNAL_SCRIPT          ) { return true  } /* internal scripts always at top */
                    if (rhs == URL_INTERNAL_SCRIPT          ) { return false } /* internal scripts always at top */
                    if (lhs == URL_INTERNAL_ATTRIBUTE_SCRIPT) { return true  } /* internal scripts in attribute always at top */
                    if (rhs == URL_INTERNAL_ATTRIBUTE_SCRIPT) { return false } /* internal scripts in attribute always at top */
                    return lhs.decodePunycode() < rhs.decodePunycode() /* alphabetical order */
                })

                TableCustom(
                    selected: .constant([]),
                    isVisibleHeader: false,
                    isFocusable: false,
                    isScrollable: false,
                    selectionType: .none,
                    head: {
                        TableCustom_HeadCell(
                            size: .flexible(),
                            spacing: 2,
                            alignment: .leading
                        ) { EmptyView() }
                        TableCustom_HeadCell(
                            size: .fixed(50),
                            spacing: 0,
                            alignment: .center
                        ) { EmptyView() }
                    },
                    bodyAsArray: frameScriptsSorted.flatMap { script in [
                        AnyView(self.PopupBody_FrameScripts_CellURLView(value: script)),
                        AnyView(self.PopupBody_FrameScripts_CellToggleView(
                            domain,
                            frameDomain,
                            script
                        ))
                    ]}
                )

            }
        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder private func PopupBody_FrameScripts_CellURLView(value: URLString) -> some View {
        switch (value) {
            case URL_INTERNAL_SCRIPT          : Text(NSLocalizedString("all internal scripts"          , comment: ""))
            case URL_INTERNAL_ATTRIBUTE_SCRIPT: Text(NSLocalizedString("all internal attribute scripts", comment: ""))
            default                           : Text(value.decodeURLString()).textSelectionPolyfill()
        }
    }

    @ViewBuilder private func PopupBody_FrameScripts_CellToggleView(_ domain: DomainName, _ frameDomain: DomainName, _ script: URLString) -> some View {
        ToggleCustom(
            isOn: Binding<Bool>(
                get: {             self.isOnGet(domain, frameDomain, script) },
                set: { newValue in self.isOnSet(domain, frameDomain, script, newValue) } ),
            size: CGSize(width: 30, height: 12)
        )
    }

    private func isOnGet(_ domain: DomainName, _ frameDomain: DomainName, _ script: URLString) -> Bool {
        if let match = popupState.match {
            switch match {
                case .noOneScript                : return ScriptsCart   .getIsOn(                frameDomain, script)
                case .exactScript                : return ScriptsManager.getIsOn(for: domain   , frameDomain, script)
                case .wildcardScript(let item, _): return ScriptsManager.getIsOn(for: item.name, frameDomain, script)
                default: break
            }
        }
        return false
    }

    private func isOnSet(_ domain: DomainName, _ frameDomain: DomainName, _ script: URLString, _ newValue: Bool) {
        if let match = popupState.match {
            switch match {
                case .noOneScript: ScriptsCart   .setIsOn(             frameDomain, script, newValue)
                case .exactScript: ScriptsManager.setIsOn(for: domain, frameDomain, script, newValue)
                case .wildcardScript:
                    let name = AllowedDomains.selectDomainAndTopDomains(domain, types: [
                        MATCH_TYPE_STRING_WILDCARD_SCRIPT
                    ]).first?.name ?? domain
                    ScriptsManager.setIsOn(
                        for: name,
                        frameDomain,
                        script,
                        newValue
                    )
                default: break
            }
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ScriptsPanel_Previews: PreviewProvider {

    struct ViewWithState: View {

        static let frames = [
            DEMO_TOPDOMAIN,
            "b.com", "б.ком",
            "r.com", "л.ком",
            "j.com", "ж.ком",
            "n.com", "з.ком",
            "i.com", "ё.ком",
            "q.com", "й.ком",
            "d.com", "д.ком",
            "f.com", "е.ком",
            "s.com", "п.ком",
            "w.com", "ф.ком",
        ]

        static let frameScripts = [
            "https://b.com/script.js",
            "https://q.com/script.js",
            "https://x.com/script.js",
        ]

        static let scriptsIsOn: Matrix3dBool = {
            var result = Matrix3dBool()
                result["js-blocker.com", "ё.com", "https://b.com/script.js"] = true
                result["js-blocker.com", "ё.com", "https://c.com/script.js"] = true
            return result
        }()

        static func generateScripts(count: Int) -> Matrix2dArrOfStr {
            var result = Matrix2dArrOfStr()
            for i in 0 ..< count {
                result[DEMO_TOPDOMAIN, Self.frames[i]] = Self.frameScripts
            }
            return result
        }

        static func generateScripts0Plus() -> Matrix2dArrOfStr {
            var result = Matrix2dArrOfStr()
                result[DEMO_TOPDOMAIN, DEMO_TOPDOMAIN] = []
            return result
        }

        @ObservedObject static private var match = ValueState<UInt>(0) { value in
            PopupState.shared.match = .noOne
            PopupState.shared.domain = DEMO_TOPDOMAIN
            PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
            PopupState.shared.scriptsIsOn = Self.scriptsIsOn
            if      (value == 0) { PopupState.shared.scripts = Self.generateScripts(count: 0) }
            else if (value == 1) { PopupState.shared.scripts = Self.generateScripts0Plus() }
            else                 { PopupState.shared.scripts = Self.generateScripts(count: Int(value) - 1) }
        }

        var body: some View {
            VStack(spacing: 0) {
                ScriptsPanel()
                    .padding(20)
                PreviewModeSelector(
                    title: "count",
                    state: Self.match,
                    modes: ["0", "0+", "1", "2", "3", "4", "5", "6", "7", "8"]
                )
            }.frame(
                width: Popup.FRAME_WIDTH
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
