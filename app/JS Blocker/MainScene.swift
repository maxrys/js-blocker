
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI

struct MainScene: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL

    @EnvironmentObject var domainsState: DomainsState
    @State private var isShowPopover = false

    private let messageBox: MessageBox

    init() {
        self.messageBox = MessageBox()
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
                    self.PanelButton(icon: Image(systemName: "square.and.arrow.up"  ), text: NSLocalizedString("export" , comment: ""), isDisabled: self.domainsState.selectedRows.isEmpty) { self.onClickExport() }
                    self.PanelButton(icon: Image(systemName: "square.and.arrow.down"), text: NSLocalizedString("import" , comment: "")                                                    ) { self.onClickImport() }
                    self.PanelButton(icon: Image(systemName: "hammer"               ), text: NSLocalizedString("install", comment: "")                                                    ) { self.isShowPopover = true }
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

                    TableCustom(
                        selected: self.domainsState.getBinding(\.selectedRows),
                        isVisibleHeader: true,
                        isFocusable: true,
                        selectionType: .multiple,
                        head: {
                            TableCustom_HeadCell(
                                size: .flexible(),
                                spacing: 1,
                                alignment: .leading
                            ) { Text(NSLocalizedString("domain name", comment: "")).font(.system(size: 11)) }
                            TableCustom_HeadCell(
                                size: .fixed(90),
                                spacing: 1,
                                alignment: .center
                            ) { Text(NSLocalizedString("wildcard", comment: "")).font(.system(size: 11)) }
                            TableCustom_HeadCell(
                                size: .fixed(40),
                                spacing: 1
                            ) { EmptyView() }
                        },
                        bodyAsArray: self.domainsState.data.flatMap { domain in [
                            AnyView(Text(domain.nameDecoded)),
                            AnyView(Text(domain.isWildcard ? NSLocalizedString("yes", comment: "") : NSLocalizedString("no" , comment: ""))),
                            AnyView(self.ButtonOpenURLOrDummy(domain.name))
                        ]}
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
                AllowedDomains.dump()
            }
        }
    }

    @ViewBuilder private func ButtonOpenURLOrDummy(_ domainName: String) -> some View {
        if let url = URL(string: "https://\(domainName)") {
            Button {
                openURL(url)
                Logger.customLog("open URL: \(url)")
            } label: {
                Image(systemName: "safari")
                    .contentShape(Circle())
                    .opacity(0.7)
            }
            .buttonStyle(.plain)
            .pointerStyleLinkPolyfill()
        } else {
            Color.clear
                .frame(width: 10, height: 10)
        }
    }

    @ViewBuilder private func FieldSearch() -> some View {
        TextField(
            NSLocalizedString("Search", comment: ""),
            text: self.domainsState.getBinding(\.filterByName)
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
            if (!self.domainsState.filterByName.isEmpty) {
                Button { self.domainsState.filterByName = "" } label: {
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

    @ViewBuilder private func PanelButton(icon: Image, text: String? = nil, isDisabled: Bool = false, onClick: @escaping () -> Void = {}) -> some View {
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
            .disabled(isDisabled)
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
            isDisabled: self.domainsState.selectedRows.isEmpty,
            colorStyle: .custom(text: nil, background: nil),
            flexibility: .size(120)
        ) {
            let count = self.domainsState.selectedRows.count
            if (count > 0) {
                if (AllowedDomains.delete(self.domainsState.selectedRowsToNames)) {
                    Task {
                        self.domainsState.dataReload()
                        MessageBox.insert(
                            type: .ok,
                            title: String(format: NSLocalizedString("%d records have been deleted", comment: ""), count),
                            lifeTime: .time(3)
                        )
                    }
                }
            }
        }
    }

    func onClickExport() {
        if (self.domainsState.selectedRows.count > 0) {
            Features.export(
                items: self.domainsState.selectedRowsToData
            )
        }
    }

    func onClickImport() {
        Features.import()
        self.domainsState.dataReload()
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        MainScene()
            .frame(width: 500, height: 500)
            .environmentObject(DomainsState.shared)
    }
}
