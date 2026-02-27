
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct MainScene: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL
    @EnvironmentObject var wdState: WhiteDomainsState
    @State private var isShowPopover = false

    private let messageBox: MessageBox

    init() {
        self.messageBox = MessageBox()
    }

    private let tableColumns = [
        (title: NSLocalizedString("domain name", comment: ""), settings: GridItem(.flexible(), spacing: 1, alignment: .leading)),
        (title: NSLocalizedString("global"     , comment: ""), settings: GridItem(.fixed(90) , spacing: 1)),
        (title: NSLocalizedString(EMPTY_STRING , comment: ""), settings: GridItem(.fixed(40) , spacing: 1)),
    ]

    private var tableCells: [[AnyView]] {
        var result: [[AnyView]] = []
        for domain in self.wdState.data {
            let url = URL(string: "https://\(domain.name)")
            result.append([
                AnyView(Text(domain.nameDecoded)),
                AnyView(Text(domain.isGlobal ? NSLocalizedString("yes", comment: "") : NSLocalizedString("no", comment: ""))),
                url != nil ?
                    AnyView(self.ButtonOpenURL(url!)) :
                    AnyView(Color.clear.frame(width: 10, height: 10))
            ])
        }
        return result
    }

    public var body: some View {
        VStack(spacing: 0) {

            self.messageBox

            VStack(spacing: 20) {

                /* MARK: Title */

                Text(NSLocalizedString("Domains where JavaScript is allowed", comment: ""))
                    .font(.system(size: 16, weight: .bold))

                /* MARK: Panel */

                HStack(spacing: 10) {
                    self.FieldSearch()
                    Color.clear.frame(width: 1, height: 10)
                    self.PanelButton(icon: Image(systemName: "square.and.arrow.up"  ), text: NSLocalizedString("export" , comment: ""), disabled: self.wdState.selectedRows.isEmpty) { self.onClickExport() }
                    self.PanelButton(icon: Image(systemName: "square.and.arrow.down"), text: NSLocalizedString("import" , comment: "")                                             ) { self.onClickImport() }
                    self.PanelButton(icon: Image(systemName: "hammer"               ), text: NSLocalizedString("install", comment: "")                                             ) { self.isShowPopover = true }
                        .popover(
                            isPresented: self.$isShowPopover,
                            arrowEdge: .bottom
                        ) {
                            InstallPopup()
                        }
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.mainScene.panelBackground)
                )
                .frame(maxWidth: .infinity)

                /* MARK: Table + Note */

                VStack(spacing: 7) {

                    Table(
                        selectedRows: self.wdState.getBinding(\.selectedRows),
                        columns: self.tableColumns,
                        data: self.tableCells
                    )

                    Text(
                        NSLocalizedString(
                            "note: New Domains are added in Safari via the \"JS Blocker\" pop-up.", comment: ""
                        )
                    )
                    .font(.system(size: 11))
                    .multilineTextAlignment(.center)
                    .opacity(0.5)

                }

                self.ButtonDelete()

            }
            .padding(20)
            .padding(.bottom, 3)
            .onAppear {
                WhiteDomains.dump()
            }
        }
    }

    @ViewBuilder private func FieldSearch() -> some View {
        TextField(
            NSLocalizedString("Search", comment: ""),
            text: self.wdState.getBinding(\.filterByName)
        )
        .textFieldStyle(.plain)
        .padding(.horizontal, 32)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.mainScene.panelTextFieldBackground)
                .shadow(
                    color: .black.opacity(0.5),
                    radius: 1,
                    y: 0
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 5))
        .overlayPolyfill(alignment: .leading) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundPolyfill(Color.label.opacity(0.3))
                .offset(x: 8)
        }
        .overlayPolyfill(alignment: .trailing) {
            if (!self.wdState.filterByName.isEmpty) {
                Button { self.wdState.filterByName = "" } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 16))
                        .foregroundPolyfill(Color.label.opacity(0.3))
                        .background(self.colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .pointerStyleLinkPolyfill()
                .offset(x: -5)
            }
        }
    }

    @ViewBuilder private func PanelButton(icon: Image, text: String? = nil, disabled: Bool = false, onClick: @escaping () -> Void = {}) -> some View {
        VStack(spacing: 3) {

            Button { onClick() } label: {
                icon.font(.system(size: 12))
                    .frame(width: 40, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.mainScene.panelButtonBackground)
                            .shadow(
                                color: .black.opacity(0.5),
                                radius: 1,
                                y: 0
                            )
                    ).contentShape(
                        RoundedRectangle(cornerRadius: 5)
                    )
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            .pointerStyleLinkPolyfill()

            Text(text ?? ZERO_WIDTH_SPACE)
                .font(.system(size: 9))
                .lineLimit(1)
                .opacity(0.5)

        }.frame(width: 40)
    }

    @ViewBuilder private func ButtonDelete() -> some View {
        ButtonCustom(
            NSLocalizedString("delete", comment: ""),
            colorStyle: .custom(text: nil, background: nil),
            flexibility: .size(120)
        ) {
            if (self.wdState.selectedRows.count > 0) {
                if (WhiteDomains.deleteByNames(names: self.wdState.selectedRowsToPrimaryKeys)) {
                    Task {
                        self.wdState.dataReload()
                    }
                }
            }
        }.disabled(
            self.wdState.selectedRows.isEmpty
        )
    }

    @ViewBuilder private func ButtonOpenURL(_ url: URL) -> some View {
        Button {
            openURL(url)
        } label: {
            Image(systemName: "safari")
                .contentShape(Circle())
                .opacity(0.7)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
    }

    func onClickExport() {
        if (self.wdState.selectedRows.count > 0) {
            Features.export(data: self.wdState.selectedRowsToData)
        }
    }

    func onClickImport() {
        Features.import()
        self.wdState.dataReload()
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        MainScene()
            .frame(width: 500, height: 500)
            .environmentObject(WhiteDomainsState.shared)
    }
}
