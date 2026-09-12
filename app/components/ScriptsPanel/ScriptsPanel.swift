
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ScriptsPanel: View {

    static let ICON_OPENER  = Image("symbol Icon Scripts")

    @StateObject private var popupState = PopupState.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var isOpened = false

    private var currentScripts: [FrameDomainName: [URLString]] {
        PopupState.shared.scripts[self.currentDomainName] ?? [:]
    }

    private var hasScripts: Bool {
        !self.currentScripts.values.allSatisfy(\.isEmpty)
    }

    private var totalCount: Int {
        self.currentScripts.values.reduce(0) { total, scripts in
            total + scripts.count
        }
    }

    private var isByScriptMode: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOneScript || match.isExactScript || match.isWildcardScript
        }
    }

    private var isVisibleFrames: Bool {
        self.popupState.match.ifNil(defaultValue: false) { match in
            match.isNoOne || match.isNoOneScript
        }
    }

    private let currentDomainName: CurrentDomainName
    private let currentDomainNameDecoded: CurrentDomainName
    private let openerIconOffset: CGPoint

    init(
        domainName: CurrentDomainName,
        openerIconOffset: CGPoint = CGPoint(x: 0, y: 0)
    ) {
        self.openerIconOffset         = openerIconOffset
        self.currentDomainName        = domainName
        self.currentDomainNameDecoded = domainName.decodePunycode()
    }

    private var sortedDomainNames: [FrameDomainName] {
        self.currentScripts.keys.sorted(by: { (lhs, rhs) in
            let lhsDecoded = lhs.decodePunycode()
            let rhsDecoded = rhs.decodePunycode()
            if (lhsDecoded == self.currentDomainNameDecoded) { return true  } /* current domain always at top */
            if (rhsDecoded == self.currentDomainNameDecoded) { return false } /* current domain always at top */
            return lhsDecoded < rhsDecoded /* alphabetical order */
        })
    }

    public var body: some View {
        self.OpenerView()
            .popover(isPresented: self.$isOpened, arrowEdge: .trailing) {
                self.PopupView()
            }
    }

    @ViewBuilder private func OpenerView() -> some View {
        Button {
            self.isOpened.toggle()
        } label: {
            Group {
                Self.ICON_OPENER
                    .font(.system(size: 24))
                    .foregroundPolyfill(
                        self.isByScriptMode ?
                            Color.scriptsPanel.openerActiveBackground :
                            Color.scriptsPanel.openerBackground
                    ).offset(
                        x: self.openerIconOffset.x,
                        y: self.openerIconOffset.y
                    )
            }
            .padding(7)
            .background(Color.white.opacity(0.1))
            .contentShape(Circle())
            .focusEffect (Circle())
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
        .focusable(false)
    }

    @ViewBuilder private func PopupView() -> some View {
        VStack(spacing: 0) {

            self.PopupHead_TitleView()

            if (self.isVisibleFrames) {
                self.PopupSriptsModeToggleView()
                    .overlayPolyfill(alignment: .trailing) {
                        if (self.isByScriptMode) {
                            if (self.isByScriptMode) {
                                RefreshButton(onClick: self.popupState.jsGetScripts)
                                    .foregroundPolyfill(Color.scriptsPanel.popupTitle)
                                    .offset(x: -30)
                            }
                        }
                    }
            }

            if (self.isByScriptMode) {
                Group {
                    if (self.totalCount < 20) { self.PopupBodyView() }
                    else         { ScrollView { self.PopupBodyView() }.frame(height: 600) }
                }.overlayPolyfill(alignment: .top) {
                    self.PopupHead_ShadowView(height: 5)
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
        .padding(20)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func PopupBodyView() -> some View {
        if (self.hasScripts) {
            VStack(spacing: 10) {
                ForEach(self.sortedDomainNames, id: \.self) { frameDomainName in
                    self.PopupBody_FrameScriptsView(
                        frameDomainName: frameDomainName,
                        frameScripts: self.currentScripts[
                            frameDomainName
                        ] ?? []
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        } else {
            Text(NSLocalizedString("no strips", comment: ""))
                .multilineTextAlignment(.center)
                .font(.headline)
                .padding(30)
        }
    }

    @ViewBuilder private func PopupBody_FrameScriptsView(
        frameDomainName: FrameDomainName,
        frameScripts: [URLString]
    ) -> some View {
        VStack(spacing: 0) {

            if (self.currentDomainName != frameDomainName) {

                HStack(spacing: 10) {
                    Text(NSLocalizedString("Frame with domain:", comment: ""))
                        .font(.headline)
                        .opacity(0.5)
                    Text(frameDomainName.decodePunycode())
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
                        self.currentDomainName,
                        frameDomainName,
                        script
                    ))
                ]}
            )

        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder private func PopupBody_FrameScripts_CellURLView(value: URLString) -> some View {
        switch (value) {
            case URL_INTERNAL_SCRIPT          : Text(NSLocalizedString("all internal scripts"          , comment: ""))
            case URL_INTERNAL_ATTRIBUTE_SCRIPT: Text(NSLocalizedString("all internal attribute scripts", comment: ""))
            default                           : Text(value.decodeURLString()).textSelectionPolyfill()
        }
    }

    @ViewBuilder private func PopupBody_FrameScripts_CellToggleView(_ domainName: DomainName, _ frameDomainName: DomainName, _ script: URLString) -> some View {
        ToggleCustom(
            isOn: Binding<Bool>(
                get: {             self.isOnGet(domainName, frameDomainName, script) },
                set: { newValue in self.isOnSet(domainName, frameDomainName, script, newValue) } ),
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

        static let topFrame = "js-blocker.com"

        static let frames = [
            topFrame,
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
                result[topFrame, Self.frames[i]] = Self.frameScripts
            }
            return result
        }

        var body: some View {
            VStack(spacing: 0) {
                ScriptsPanel(domainName : "js-blocker.com")
                    .background(Color.colorButtonCapsuleVioletBottom)
                    .onAppear {
                        PopupState.shared.match = .noOne
                        PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
                        PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
                        PopupState.shared.scriptsIsOn = Self.scriptsIsOn
                        PopupState.shared.scripts = Self.generateScripts(count: 6)
                    }
            }.frame(
                width: Popup.FRAME_WIDTH
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
