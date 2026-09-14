
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ScriptsPanel: View {

    static let ICON_OPENER  = Image("symbol Icon Scripts")
    static let ICON_REFRESH = Image("symbol Icon Scripts Refresh")

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
            .popover(isPresented: self.$isOpened, arrowEdge: .bottom) {
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
                        Color.popup.buttonSettings
                    ).offset(
                        x: self.openerIconOffset.x,
                        y: self.openerIconOffset.y
                    )
            }
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

            Group {
                if (self.totalCount < 20) { self.PopupBodyView() }
                else         { ScrollView { self.PopupBodyView() }.frame(height: 600) }
            }.overlayPolyfill(alignment: .top) {
                self.PopupHead_ShadowView(height: 5)
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
                        alignment: .leading
                    ) { EmptyView() }
                },
                bodyAsArray: frameScripts.sorted().flatMap { script in [
                    AnyView(self.PopupBody_FrameScripts_CellURLView(value: script)),
                ]}
            )

        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder private func PopupBody_FrameScripts_CellURLView(value: URLString) -> some View {
        Text(value.decodeURLString())
            .textSelectionPolyfill()
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

        static func generateScripts(count: Int) -> Matrix2dArrOfStr {
            var result = Matrix2dArrOfStr()
            for i in 0 ..< count {
                result[topFrame, Self.frames[i]] = Self.frameScripts
            }
            return result
        }

        static func generateScripts0Plus() -> Matrix2dArrOfStr {
            var result = Matrix2dArrOfStr()
                result[self.topFrame, self.topFrame] = []
            return result
        }

        @ObservedObject static private var match = ValueState<UInt>(0) { value in
            PopupState.shared.match = .noOne
            PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
            if      (value == 0) { PopupState.shared.scripts = Self.generateScripts(count: 0) }
            else if (value == 1) { PopupState.shared.scripts = Self.generateScripts0Plus() }
            else                 { PopupState.shared.scripts = Self.generateScripts(count: Int(value) - 1) }
        }

        var body: some View {
            VStack(spacing: 0) {
                ScriptsPanel(domainName: ScriptsPanel_Previews.ViewWithState.topFrame)
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
