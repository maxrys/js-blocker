
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct Table: View {

    typealias Columns = [(
        title   : String,
        settings: GridItem
    )]

    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedRows: Set<Int>
    @State private var lastSelectedRow: Int = 0
    @State private var appIsFocused: Bool = true

    private let columns: Columns
    private let data: [[AnyView]]

    init(selectedRows: Binding<Set<Int>>, columns: Columns, data: [[AnyView]]) {
        self._selectedRows = selectedRows
        self.columns = columns
        self.data = data
    }

    private func rowTextColor(_ isSelected: Bool) -> Color {
        if (isSelected == true && self.appIsFocused == true) { return Color.white }
        if (isSelected != true && self.appIsFocused == true) { return Color.label }
        if (isSelected == true && self.appIsFocused != true) { return Color.label }
        if (isSelected != true && self.appIsFocused != true) { return Color.label }
        return Color.clear
    }

    private func rowBackgroundColor(_ isSelected: Bool, _ isEven: Bool) -> Color {
        if (isSelected != true && isEven != true                             ) { return Color.table.bodyRowBackground }
        if (isSelected != true && isEven == true                             ) { return Color.table.bodyRowEvenBackground }
        if (isSelected == true && isEven != true && self.appIsFocused == true) { return Color.selectedContentBackground.opacity(0.9) }
        if (isSelected == true && isEven == true && self.appIsFocused == true) { return Color.selectedContentBackground }
        if (isSelected == true && isEven != true && self.appIsFocused != true) { return Color.selectedContentUnactiveBackground.opacity(0.9) }
        if (isSelected == true && isEven == true && self.appIsFocused != true) { return Color.selectedContentUnactiveBackground }
        return Color.clear
    }

    public var body: some View {
        VStack {

            let gridColumns: [GridItem] = (0 ... columns.count - 1).map { index in
                self.columns[index].settings
            }

            VStack(spacing: 0) {

                /* MARK: Head */

                LazyVGrid(columns: gridColumns, spacing: 0) {
                    ForEach(self.columns.indices, id: \.self) { index in
                        Text("\(self.columns[index].title)")
                            .font(.system(size: 11))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: self.columns[index].settings.alignment ?? .center)
                    }
                }.background(Color.table.headBackground)

                Color(self.colorScheme == .dark ? .white : .black)
                    .frame(height: 1)
                    .opacity(0.2)

                /* MARK: Body */

                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 0) {
                        ForEach(self.data          .indices, id: \.self) { rowIndex in
                        ForEach(self.data[rowIndex].indices, id: \.self) { colIndex in
                            let isSelected = self.selectedRows.contains(rowIndex)
                            let isEven = rowIndex % 2 == 0
                            self.data[rowIndex][colIndex]
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: self.columns[colIndex].settings.alignment ?? .center)
                                .foregroundPolyfill(self.rowTextColor(isSelected))
                                .background(self.rowBackgroundColor(isSelected, isEven))
                                .onTapGesture { self.onClickRow(rowIndex) }
                        }}
                    }
                }.background(Color.table.bodyBackground)

            }

        }
        .focusable()
        .onKeyPressForSelectAll() {
            Task {
                self.selectedRows = Set(0 ..< self.data.count)
            }
        }
        .onAppBecomeForeground {
            self.appIsFocused = true
        }
        .onAppBecomeBackground {
            self.appIsFocused = false
        }
    }

    public func onClickRow(_ rowIndex: Int) {
        if (NSEvent.isPressedCommandButton) {
            self.selectedRows.toggle(rowIndex)
        }
        else if (NSEvent.isPressedShiftButton) {
            let lastSelectedRow = self.selectedRows.isEmpty ? 0 : self.lastSelectedRow
            if (lastSelectedRow >= rowIndex)
                 { self.selectedRows.formUnion(rowIndex ... lastSelectedRow) }
            else { self.selectedRows.formUnion(lastSelectedRow ... rowIndex) }
        }
        else {
            self.selectedRows.removeAll()
            self.selectedRows.insert(rowIndex)
        }
        self.lastSelectedRow = rowIndex
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct Table_Previews: PreviewProvider {
    static var previews: some View {
        Table(
            selectedRows: Binding.constant([4]),
            columns: [
                (title: NSLocalizedString("Values", comment: ""), settings: GridItem(.flexible(), spacing: 0, alignment: .leading)),
                (title: EMPTY_STRING                            , settings: GridItem(.fixed(30) , spacing: 0)),
            ],
            data: [
                [AnyView(Text("Value 1")), AnyView(Image(systemName: "1.square"))],
                [AnyView(Text("Value 2")), AnyView(Image(systemName: "2.square"))],
                [AnyView(Text("Value 3")), AnyView(Image(systemName: "3.square"))],
                [AnyView(Text("Value 4")), AnyView(Image(systemName: "4.square"))],
                [AnyView(Text("Value 5")), AnyView(Image(systemName: "5.square"))],
            ]
        )
        .padding(20)
        .frame(width: 250)
    }
}
