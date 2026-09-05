
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ScriptsPanel: View {

    static let ICON_OPENER  = Image("symbol Icon Scripts")
    static let ICON_REFRESH = Image("symbol Icon Scripts Refresh")

    @StateObject private var popupState = PopupState.shared
    @Environment(\.colorScheme) private var colorScheme
    @Binding private var scripts: Matrix2dArrOfStr
    @Binding private var scriptsIsOn: Matrix3dBool
    @State private var isOpened = false

    private var currentScripts: [FrameDomainName: [URLString]] {
        self.scripts[self.currentDomainName] ?? [:]
    }

    private var hasScripts: Bool {
        !self.currentScripts.values.allSatisfy(\.isEmpty)
    }

    private var totalCount: Int {
        self.currentScripts.values.reduce(0) { total, scripts in
            total + scripts.count
        }
    }

    private let currentDomainName: CurrentDomainName
    private let currentDomainNameDecoded: CurrentDomainName
    private let openerIconOffset: CGPoint

    init(
        domainName: CurrentDomainName,
        scripts: Binding<Matrix2dArrOfStr>,
        scriptsIsOn: Binding<Matrix3dBool>,
        openerIconOffset: CGPoint = CGPoint(x: 0, y: 0)
    ) {
        self.openerIconOffset         = openerIconOffset
        self.currentDomainName        = domainName
        self.currentDomainNameDecoded = domainName.decodePunycode()
        self._scripts                 = scripts
        self._scriptsIsOn             = scriptsIsOn
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
        let isActive = self.popupState.isNoOneScriptMode
        Button {
            self.isOpened.toggle()
        } label: {
            Group {
                Self.ICON_OPENER
                    .font(.system(size: 24))
                    .foregroundPolyfill(
                        isActive ?
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
                .overlayPolyfill(alignment: .trailing) {
                    self.PopupHead_ButtonRefreshView()
                        .offset(x: -11.5)
                }

            if (self.popupState.match?.isNoOne == true) {
                self.PopupSriptsModeToggleView()
            }

            if (self.popupState.isNoOneScriptMode ||
                self.popupState.match?.isExactScript    == true ||
                self.popupState.match?.isWildcardScript == true ) {
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
        Text(NSLocalizedString("External Scripts", comment: ""))
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(15)
            .foregroundPolyfill(Color.scriptsPanel.popupTitle)
            .background(Color.scriptsPanel.popupTitleBackground)
    }

    @ViewBuilder private func PopupHead_ButtonRefreshView() -> some View {
        Button {
            self.popupState.jsGetScripts()
        } label: {
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: 30, height: 30)
                .overlayPolyfill {
                    Self.ICON_REFRESH
                        .font(.system(size: 18))
                        .foregroundPolyfill(Color.scriptsPanel.popupTitle)
                }
                .clipShape   (Capsule())
                .contentShape(Capsule())
                .focusEffect (Capsule())
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
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
            text: NSLocalizedString("By Scripts", comment: ""),
            isOn: self.$popupState.isNoOneScriptMode,
            size: CGSize(width: 50, height: 20),
            font: .system(size: 18)
        ).padding(20)
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

                Text(String(format: NSLocalizedString("Domain: %@", comment: ""), frameDomainName.decodePunycode()))
                    .font(.headline)
                    .padding(.bottom, 10)

                Rectangle()
                    .fill(
                        self.colorScheme == .dark ?
                            .white.opacity(0.5) :
                            .black.opacity(0.5)
                    ).frame(height: 1)
            }

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
                bodyAsArray: frameScripts.sorted().flatMap { script in [
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
        Text(value.decodeURLString())
            .textSelectionPolyfill()
    }

    @ViewBuilder private func PopupBody_FrameScripts_CellToggleView(_ domainName: DomainName, _ frameDomainName: DomainName, _ script: URLString) -> some View {
        ToggleCustom(
            isOn: Binding<Bool>(
                get: {             self.scriptsIsOnGet(domainName, frameDomainName, script) },
                set: { newValue in self.scriptsIsOnSet(domainName, frameDomainName, script, newValue) } ),
            size: CGSize(width: 30, height: 12)
        )
    }

    private func scriptsIsOnGet(_ domainName: DomainName, _ frameDomainName: DomainName, _ script: URLString) -> Bool {
        self.scriptsIsOn[domainName, frameDomainName, script, default: false]
    }

    private func scriptsIsOnSet(_ domainName: DomainName, _ frameDomainName: DomainName, _ script: URLString, _ newValue: Bool) {
        var result: ExecuteResult = .failure
        if (newValue == true) { result = AllowedScripts.insert(domain: domainName, frameDomain: frameDomainName, url: script) }
        if (newValue != true) { result = AllowedScripts.delete(domain: domainName, frameDomain: frameDomainName, url: script) }
        if case .success = result {
            self.scriptsIsOn[domainName, frameDomainName, script] = newValue
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ScriptsPanel_Previews: PreviewProvider {
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
    static func scripts(count: Int) -> Matrix2dArrOfStr {
        var result = Matrix2dArrOfStr()
        for i in 0 ..< count {
            result[topFrame, Self.frames[i]] = Self.frameScripts
        }
        return result
    }
    static public var previews: some View {
        VStack(spacing: 10) {
            ForEach(0 ..< 10, id: \.self) { i in
                ScriptsPanel(
                    domainName : "js-blocker.com",
                    scripts    : .constant(Self.scripts(count: i)),
                    scriptsIsOn: .constant(Self.scriptsIsOn)
                ).background(Color.colorButtonCapsuleVioletBottom)
            }
            Spacer()
        }
        .padding(20)
        .frame(width: 200, height: 550)
        .background(Color.popup.ruleExactBackground)
    }
}

struct ScriptsPanel_NoScripts_Previews: PreviewProvider {
    static public var previews: some View {
        let scriptsEmpty1 = Matrix2dArrOfStr()
        let scriptsEmpty2: Matrix2dArrOfStr = {
            var result = Matrix2dArrOfStr()
                result["js-blocker.com", "js-blocker.com"] = []
            return result
        }()
        VStack(spacing: 10) {
            ScriptsPanel(
                domainName : "js-blocker.com",
                scripts    : .constant(scriptsEmpty1),
                scriptsIsOn: .constant(Matrix3dBool())
            ).background(Color.colorButtonCapsuleVioletBottom)
            ScriptsPanel(
                domainName : "js-blocker.com",
                scripts    : .constant(scriptsEmpty2),
                scriptsIsOn: .constant(Matrix3dBool())
            ).background(Color.colorButtonCapsuleVioletBottom)
            Spacer()
        }
        .padding(20)
        .frame(width: 200, height: 400)
        .background(Color.popup.ruleExactBackground)
    }
}
