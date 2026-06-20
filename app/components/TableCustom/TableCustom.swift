
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct TableCustom: View {

    enum SelectionType {
        case single
        case multiple
        case none
    }

    @Environment(\.colorScheme) private var colorScheme
    @Binding private var selectedRows: Set<Int>
    @State private var lastSelectedRow: Int = 0
    @State private var appIsFocused: Bool = true

    private let isVisibleHeader: Bool
    private let windowID: String?
    private let isFocusable: Bool
    private let isScrollable: Bool
    private let selectionType: SelectionType
    private let headCellPadding: EdgeInsets
    private let bodyCellPadding: EdgeInsets
    private let headCells: [TableCustom_HeadCell]
    private let bodyCells: [any View]

    private var rowsCount: Int {
        self.bodyCells.count / self.headCells.count
    }

    init(
        selected selectedRows: Binding<Set<Int>>,
        windowID: String? = nil,
        isVisibleHeader: Bool = true,
        isFocusable: Bool = true,
        isScrollable: Bool = true,
        selectionType: SelectionType = .multiple,
        headCellPadding: EdgeInsets = .init(top: 7, leading: 10, bottom: 7, trailing: 10),
        bodyCellPadding: EdgeInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8),
        @ViewBuilderArray<TableCustom_HeadCell> head headCells: () -> [TableCustom_HeadCell],
        bodyAsArray bodyCells: [any View]
    ) {
        self._selectedRows = selectedRows
        self.windowID = windowID
        self.isVisibleHeader = isVisibleHeader
        self.isFocusable = isFocusable
        self.isScrollable = isScrollable
        self.selectionType = selectionType
        self.headCellPadding = headCellPadding
        self.bodyCellPadding = bodyCellPadding
        self.headCells = headCells()
        self.bodyCells = bodyCells
    }

    init(
        selected selectedRows: Binding<Set<Int>>,
        windowID: String? = nil,
        isVisibleHeader: Bool = true,
        isFocusable: Bool = true,
        isScrollable: Bool = true,
        selectionType: SelectionType = .multiple,
        headCellPadding: EdgeInsets = .init(top: 7, leading: 10, bottom: 7, trailing: 10),
        bodyCellPadding: EdgeInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8),
        @ViewBuilderArray<TableCustom_HeadCell> head headCells: () -> [TableCustom_HeadCell],
        @ViewBuilderArray<View> bodyAsViews bodyCells: () -> [any View]
    ) {
        self._selectedRows = selectedRows
        self.windowID = windowID
        self.isVisibleHeader = isVisibleHeader
        self.isFocusable = isFocusable
        self.isScrollable = isScrollable
        self.selectionType = selectionType
        self.headCellPadding = headCellPadding
        self.bodyCellPadding = bodyCellPadding
        self.headCells = headCells()
        self.bodyCells = bodyCells()
    }

    private var gridColumns: [GridItem] {
        (0 ... self.headCells.count - 1).compactMap { index in
            guard let cell = self.headCells[safe: index] else { return nil }
            return GridItem(cell.size, spacing: cell.spacing, alignment: cell.alignment)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {

            /* MARK: Head */

            if (self.isVisibleHeader) { VStack(spacing: 0) {

                LazyVGrid(columns: gridColumns, spacing: 0) {
                    ForEach(self.headCells.indices, id: \.self) { index in
                        if let cell = self.headCells[safe: index] {
                            cell.id(index)
                                .padding(self.headCellPadding)
                                .frame(maxWidth: .infinity, maxHeight: .infinity,
                                    alignment: cell.alignment ?? .center
                                )
                        }
                    }
                }.background(Color.tableCustom.headBackground)

                self.Delimiter()

            }}

            /* MARK: Body */

            let bodyGrid = LazyVGrid(columns: gridColumns, spacing: 0) {
                ForEach(self.bodyCells.indices, id: \.self) { index in
                    if let cell = self.bodyCells[safe: index] {
                        let rowIndex = index / self.headCells.count
                        let colIndex = index % self.headCells.count
                        let isSelected = self.selectedRows.contains(rowIndex)
                        let isEven = rowIndex % 2 == 0
                        AnyView(cell).id(index)
                            .padding(self.bodyCellPadding)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: self.headCells[safe: colIndex]?.alignment ?? .center)
                            .foregroundPolyfill(Color.tableCustom.rowTextColor(isSelected, self.appIsFocused))
                            .background(Color.tableCustom.rowBackgroundColor(isSelected, isEven, self.appIsFocused))
                            .onTapGesture { self.onClickRow(rowIndex) }
                    }
                }
            }

            if self.isScrollable {
                ScrollView { bodyGrid }.background(Color.tableCustom.bodyBackground)
            } else         { bodyGrid  .background(Color.tableCustom.bodyBackground) }

        }
        .focusable(self.isFocusable)
        .onKeyPressForSelectAll() {
            Task {
                self.selectedRows = Set(0 ..< self.rowsCount)
            }
        }
        .onWinBecomeForeground { window in if (self.windowID != nil && window.ID == self.windowID) { self.appIsFocused = true } }
        .onWinBecomeBackground { window in if (self.windowID != nil && window.ID == self.windowID) { self.appIsFocused = false } }
        .onAppBecomeForeground {           if (self.windowID == nil                              ) { self.appIsFocused = true } }
        .onAppBecomeBackground {           if (self.windowID == nil                              ) { self.appIsFocused = false } }
    }

    @ViewBuilder private func Delimiter() -> some View {
        Color(
            self.colorScheme == .dark ?
                .white :
                .black
        )
        .frame(height: 1)
        .opacity(0.2)
    }

    public func onClickRow(_ rowIndex: Int) {
        switch (self.selectionType) {
            case .single:
                self.selectedRows.removeAll()
                self.selectedRows.insert(rowIndex)
            case .multiple:
                if      (NSEvent.isPressedCommandButton) { self.selectedRows.toggle(rowIndex) }
                else if (NSEvent.isPressedShiftButton) {
                    let lastSelectedRow = self.selectedRows.isEmpty ? 0 : self.lastSelectedRow
                    if (lastSelectedRow >= rowIndex) { self.selectedRows.formUnion(rowIndex ... lastSelectedRow) }
                    else                             { self.selectedRows.formUnion(lastSelectedRow ... rowIndex) }
                } else {
                    self.selectedRows.removeAll()
                    self.selectedRows.insert(rowIndex)
                }
                self.lastSelectedRow = rowIndex
            default:
                break
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct TableCustom_Previews1: PreviewProvider {
    struct ViewWithState: View {
        @State private var selected: Set<Int> = [4]
        var body: some View {
            TableCustom(
                selected: self.$selected,
                isVisibleHeader: true,
                isFocusable: true,
                head: {
                    TableCustom_HeadCell(
                        size: .flexible(),
                        spacing: 0,
                        alignment: .leading
                    ) { Text(NSLocalizedString("Values", comment: "")).font(.system(size: 11)) }
                    TableCustom_HeadCell(
                        size: .fixed(30),
                        spacing: 0
                    ) { EmptyView() }
                },
                bodyAsArray: [
                    AnyView(Text("Value 1")), AnyView(Image(systemName: "1.circle")),
                    AnyView(Text("Value 2")), AnyView(Image(systemName: "2.circle")),
                    AnyView(Text("Value 3")), AnyView(Image(systemName: "3.circle")),
                    AnyView(Text("Value 4")), AnyView(Image(systemName: "4.circle")),
                    AnyView(Text("Value 5")), AnyView(Image(systemName: "5.circle")),
                ]
            )
            .padding(20)
            .frame(width: 250)
        }
    }
    static var previews: some View {
        ViewWithState()
    }
}

struct TableCustom_Previews2: PreviewProvider {
    struct ViewWithState: View {
        @State private var selected: Set<Int> = [4]
        var body: some View {
            TableCustom(
                selected: self.$selected,
                isVisibleHeader: true,
                isFocusable: true,
                head: {
                    TableCustom_HeadCell(
                        size: .flexible(),
                        spacing: 0,
                        alignment: .leading
                    ) { Text(NSLocalizedString("Values", comment: "")).font(.system(size: 11)) }
                    TableCustom_HeadCell(
                        size: .fixed(30),
                        spacing: 0
                    ) { EmptyView() }
                },
                bodyAsViews: {
                    Text("Value 1"); Image(systemName: "1.circle")
                    Text("Value 2"); Image(systemName: "2.circle")
                    Text("Value 3"); Image(systemName: "3.circle")
                    Text("Value 4"); Image(systemName: "4.circle")
                    Text("Value 5"); Image(systemName: "5.circle")
                }
            )
            .padding(20)
            .frame(width: 250)
        }
    }
    static var previews: some View {
        ViewWithState()
    }
}
