
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ScriptsPanel: View {

    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedRowsDummy: Set<Int> = []

    private let realDomainName: DomainName
    private let realDomainNameDecoded: DomainName
    private let scriptsByDomains: [DomainName: [String]]
    private let hasScripts: Bool

    init(
        realDomainName: DomainName,
        scriptsByDomains: [DomainName: [String]]
    ) {
        self.realDomainName = realDomainName
        self.realDomainNameDecoded = realDomainName.decodePunycode()
        self.scriptsByDomains = scriptsByDomains
        self.hasScripts = !self.scriptsByDomains.values.allSatisfy(\.isEmpty)
    }

    private var sortedDomainNames: [String] {
        self.scriptsByDomains.keys.sorted(by: { (lhs, rhs) in
            let lhsDecoded = lhs.decodePunycode()
            let rhsDecoded = rhs.decodePunycode()
            if (lhsDecoded == self.realDomainNameDecoded) { return true  } /* current domain always at top */
            if (rhsDecoded == self.realDomainNameDecoded) { return false } /* current domain always at top */
            return lhsDecoded < rhsDecoded /* alphabetical order */
        })
    }

    public var body: some View {
        Group {
            if (self.hasScripts) {
                VStack(spacing: 0) {

                    self.TitleView()
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            Color.scriptsPanel.titleBackground
                        )

                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(self.sortedDomainNames, id: \.self) { frameDomainName in
                                self.FrameScriptsView(
                                    frameDomainName: frameDomainName,
                                    frameScripts: self.scriptsByDomains[
                                        frameDomainName
                                    ] ?? []
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                    }.overlayPolyfill(alignment: .top) {
                        ShadowLine(
                            length: 10,
                            opacityDark: 0.5
                        )
                    }

                }
                .frame(maxWidth: .infinity)
            } else {
                Text(NSLocalizedString("No External Strips", comment: ""))
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding(30)
            }
        }
        .frame(width: self.hasScripts ? 600 : 200)
        .frame(maxHeight: 800)
        .background(
            Color.scriptsPanel.background
                .opacity(0.9)
        )
    }

    @ViewBuilder func TitleView() -> some View {
        Text(NSLocalizedString("External Scripts", comment: ""))
            .font(.headline)
    }

    @ViewBuilder func FrameScriptsView(
        frameDomainName: DomainName,
        frameScripts: [String],
    ) -> some View {
        VStack(spacing: 0) {

            if (self.realDomainName != frameDomainName) {

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
                selected: self.$selectedRowsDummy,
                isVisibleHeader: false,
                isFocusable: false,
                selectionType: .none,
                head: {
                    TableCustom_HeadCell(
                        size: .flexible(),
                        alignment: .leading
                    ) { EmptyView() }
                },
                bodyAsArray: frameScripts.sorted().flatMap { script in [
                    AnyView(
                        Text(script)
                            .textSelectionPolyfill()
                    ),
                ]}
            )

        }.frame(maxWidth: .infinity)
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ScriptsPanel_Previews: PreviewProvider {
    static var previews: some View {
        let scripts = [
            "https://b.com/script.js",
            "https://a.com/script.js",
            "https://c.com/script.js",
        ]
        ScriptsPanel(
            realDomainName: "js-blocker.com",
            scriptsByDomains: [
                "m.com" : scripts,
                "j.com" : scripts,
                "c.com" : scripts,
                "a.com" : scripts,
                "ё.com" : scripts,
                "e.com" : scripts,
                "b.com" : scripts,
                "js-blocker.com" : scripts,
                "ш.com" : scripts,
                "d.com" : scripts,
                "д.com" : scripts,
            ]
        ).frame(height: 400)
    }
}

struct ScriptsPanel_NoScripts1_Previews: PreviewProvider {
    static var previews: some View {
        ScriptsPanel(
            realDomainName: "js-blocker.com",
            scriptsByDomains: [:]
        ).frame(height: 400)
    }
}

struct ScriptsPanel_NoScripts2_Previews: PreviewProvider {
    static var previews: some View {
        ScriptsPanel(
            realDomainName: "js-blocker.com",
            scriptsByDomains: [
                "js-blocker.com": []
            ]
        ).frame(height: 400)
    }
}
