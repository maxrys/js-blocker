
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI

struct MainScene: View {

    static let ICON_CELL_MATCH_TYPE_EXACT    = Image("icon Cell Match type Exact")
    static let ICON_CELL_MATCH_TYPE_WILDCARD = Image("icon Cell Match type Wildcard")

    @Environment(\.openURL) var openURL

    @StateObject private var mainAppState = MainAppState.shared
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
                    FieldSearchCustom(text: self.mainAppState.getBinding(\.filterByName))
                    Color.clear.frame(width: 1, height: 10)
                    self.PanelButtonView(icon: Image(systemName: "square.and.arrow.up"  ), text: NSLocalizedString("export" , comment: "")) { self.onClickExport() }.disabled(self.mainAppState.selectedRows.isEmpty)
                    self.PanelButtonView(icon: Image(systemName: "square.and.arrow.down"), text: NSLocalizedString("import" , comment: "")) { self.onClickImport() }
                    self.PanelButtonView(icon: Image(systemName: "hammer"               ), text: NSLocalizedString("install", comment: "")) { self.isShowPopover = true }
                        .popover(
                            isPresented: self.$isShowPopover,
                            arrowEdge: .bottom
                        ) {
                            InstallGuide()
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
                        selected: self.mainAppState.getBinding(\.selectedRows),
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
                                size: .fixed(180),
                                spacing: 1,
                                alignment: .center
                            ) { Text(NSLocalizedString("expires at", comment: "")).font(.system(size: 11)) }
                            TableCustom_HeadCell(
                                size: .fixed(90),
                                spacing: 1,
                                alignment: .center
                            ) { Text(NSLocalizedString("type", comment: "")).font(.system(size: 11)) }
                            TableCustom_HeadCell(
                                size: .fixed(40),
                                spacing: 1
                            ) { EmptyView() }
                        },
                        bodyAsArray: self.mainAppState.items.flatMap { domain in [
                            AnyView(self.CellNameView(domain)),
                            AnyView(self.CellExpiresAtView(domain)),
                            AnyView(self.CellMatchTypeView(domain)),
                            AnyView(self.CellOpenURLView(domain))
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

                self.ButtonDeleteView()

            }
            .padding(20)
            .padding(.bottom, 3)
            .onAppear {
                AllowedDomains.dump()
                EntityVersions.dump()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .environment(\.layoutDirection, .leftToRight)
        .windowChamelionBackground(
            windowID: ThisApp.WINDOW_MAIN_ID,
            isIgnoreSafeArea: false
        )
        .onReceive(
            DistributedNotificationCenter.default.publisher(
                for: Notification.Name(EntityVersions.EVENT_NAME_FOR_ENTITY_CHANGE)
            )
        ) { publisher in
            if let messageString = publisher.object as? String {
                if let message = EntityVersions.DistributedMessasge(decode: messageString) {
                    Logger.customLog("Message \"\(EntityVersions.EVENT_NAME_FOR_ENTITY_CHANGE)\" receive: \(messageString)")
                    if (message.name == AllowedDomains.stringName) {
                        self.mainAppState.itemsReload(
                            message.version
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder private func EmptyCellView() -> some View {
        Color.clear
            .frame(width: 10, height: 10)
    }

    @ViewBuilder private func CellNameView(_ domain: ADFetchItem) -> some View {
        Text(domain.nameDecoded)
    }

    @ViewBuilder private func CellExpiresAtView(_ domain: ADFetchItem) -> some View {
        Text(domain.expiresAt != 0 ? Date(
            timeIntervalSince1970: TimeInterval(domain.expiresAt)
        ).formatConvenient : NOT_APPLICABLE)
    }

    @ViewBuilder private func CellMatchTypeView(_ domain: ADFetchItem) -> some View {
        if (domain.isWildcard != true) { Self.ICON_CELL_MATCH_TYPE_EXACT   .resizable().aspectRatio(contentMode: .fit).frame(height: 15) }
        if (domain.isWildcard == true) { Self.ICON_CELL_MATCH_TYPE_WILDCARD.resizable().aspectRatio(contentMode: .fit).frame(height: 15) }
    }

    @ViewBuilder private func CellOpenURLView(_ domain: ADFetchItem) -> some View {
        if let url = URL(string: "https://\(domain.name)") {
            Button {
                openURL(url)
                Logger.customLog("open URL: \(url)")
            } label: {
                Image(systemName: "safari")
                    .clipShape   (Circle())
                    .contentShape(Circle())
                    .focusEffect (Circle())
                    .opacity(0.7)
            }
            .buttonStyle(.plain)
            .pointerStyleLinkPolyfill()
        } else {
            self.EmptyCellView()
        }
    }

    @ViewBuilder private func PanelButtonView(icon: Image, text: String? = nil, onClick: @escaping () -> Void = {}) -> some View {
        VStack(spacing: 3) {

            ButtonCustom(
                nil, icon,
                colorStyle: .common,
                padding: .init(top: 2, leading: 2, bottom: 3, trailing: 2),
                flexibility: .infinity,
                isFlat: true,
                onClick: onClick
            )

            Text(text ?? ZERO_WIDTH_SPACE)
                .font(.system(size: 9))
                .lineLimit(1)
                .opacity(0.5)

        }
        .offset(y: 1.5)
        .frame(width: 40)
    }

    @ViewBuilder private func ButtonDeleteView() -> some View {
        ButtonCustom(
            NSLocalizedString("delete", comment: ""),
            colorStyle: .common,
            flexibility: .size(120),
            isFlat: true,
            onClick: self.onClickDelete
        ).disabled(self.mainAppState.selectedRows.isEmpty)
    }

    func onClickExport() {
        if (self.mainAppState.selectedRows.count > 0) {
            Features.export(
                items: self.mainAppState.selectedItems
            )
        }
    }

    func onClickImport() {
        Features.import()
        self.mainAppState.itemsReload()
    }

    func onClickDelete() {
        if (self.mainAppState.selectedRows.count > 0) {
            if case .success(let count) = self.mainAppState.delete(self.mainAppState.selectedNames) {
                Task {
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



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        VStack { MainScene() }
            .background(Color.NS[\.windowBackgroundColor])
            .environment(\.colorScheme, .light)
    }
}

struct MainScene_Previews_Dark: PreviewProvider {
    static var previews: some View {
        VStack { MainScene() }
            .background(Color.NS[\.windowBackgroundColor])
            .environment(\.colorScheme, .dark)
    }
}
