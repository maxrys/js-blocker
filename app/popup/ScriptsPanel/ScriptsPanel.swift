
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ScriptsPanel: View {

    static let FRAME_WIDTH: CGFloat = 500

    @StateObject private var popupState = PopupState.shared
    @Environment(\.colorScheme) private var colorScheme

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
        self.MainView().frame(
            maxWidth : .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
    }

    @ViewBuilder private func MainView() -> some View {
        if (self.hasScripts) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Text(NSLocalizedString("Scripts", comment: ""))
                            .font(.headline)
                        ButtonRefresh(
                            onClick: self.popupState.jsGetScripts
                        )
                    }
                    ForEach(self.sortedDomains, id: \.self) { frameDomain in
                        self.FrameScriptsView(
                            frameDomain: frameDomain,
                            frameScripts: self.scripts[
                                frameDomain
                            ] ?? []
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
            }.frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 10) {
                Text(NSLocalizedString("no strips", comment: ""))
                ButtonRefresh(
                    onClick: self.popupState.jsGetScripts
                )
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder private func FrameScriptsView(
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
                            alignment: .top
                        ) { EmptyView() }
                    },
                    bodyAsArray: frameScriptsSorted.flatMap { script in [
                        AnyView(self.FrameScripts_CellURLView(value: script)),
                        AnyView(self.FrameScripts_CellToggleView(
                            domain,
                            frameDomain,
                            script
                        ))
                    ]}
                )

            }
        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder private func FrameScripts_CellURLView(value: URLString) -> some View {
        switch (value) {
            case URL_INTERNAL_SCRIPT          : Text(NSLocalizedString("all internal scripts"          , comment: ""))
            case URL_INTERNAL_ATTRIBUTE_SCRIPT: Text(NSLocalizedString("all internal attribute scripts", comment: ""))
            default:
                let valueFormatted = value.decodeURLString()
                Text(valueFormatted.count > 300 ? String(valueFormatted.prefix(300)) + "..." : valueFormatted)
                    .help(valueFormatted)
        }
    }

    @ViewBuilder private func FrameScripts_CellToggleView(_ domain: DomainName, _ frameDomain: DomainName, _ script: URLString) -> some View {
        ToggleCustom(
            isOn: Binding<Bool>(
                get: {             self.isOnGet(domain, frameDomain, script) },
                set: { newValue in self.isOnSet(domain, frameDomain, script, newValue) } ),
            size: CGSize(width: 30, height: 12),
        ).padding(.top, 2)
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

enum ScriptsPanel_PreviewContentGenerator {

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
            if (Self.frames[i] == DEMO_TOPDOMAIN) {
                result[DEMO_TOPDOMAIN, Self.frames[i]]?.append(
                    "https://y.com/script-" + String(repeating: "long", count: 1000) + ".js"
                )
            }
        }
        return result
    }

    static func generateScripts0Plus() -> Matrix2dArrOfStr {
        var result = Matrix2dArrOfStr()
            result[DEMO_TOPDOMAIN, DEMO_TOPDOMAIN] = []
        return result
    }

}

struct ScriptsPanel_Previews: PreviewProvider {

    struct ViewWithState: View {

        @ObservedObject static private var match = ValueState<UInt>(0) { value in
            PopupState.shared.match = .noOneScript
            PopupState.shared.domain = DEMO_TOPDOMAIN
            PopupState.shared.ruleExact = DEMO_RULE__TOPDOMAIN
            PopupState.shared.rulesWildcard = DEMO_RULES__TOPDOMAIN
            PopupState.shared.scriptsIsOn = ScriptsPanel_PreviewContentGenerator.scriptsIsOn
            if      (value == 0) { PopupState.shared.scripts = ScriptsPanel_PreviewContentGenerator.generateScripts(count: 0) }
            else if (value == 1) { PopupState.shared.scripts = ScriptsPanel_PreviewContentGenerator.generateScripts0Plus() }
            else                 { PopupState.shared.scripts = ScriptsPanel_PreviewContentGenerator.generateScripts(count: Int(value) - 1) }
        }

        var body: some View {
            VStack(spacing: 0) {
                ScriptsPanel()
                PreviewMode(
                    title: "count",
                    state: Self.match,
                    modes: ["0", "0+", "1", "2", "3", "4", "5", "6", "7", "8"]
                )
            }
            .frame(
                width: ScriptsPanel.FRAME_WIDTH,
                height: 600
            )
            .background(
                Color.popup.ruleExactBackground
                    .opacity(0.9)
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
