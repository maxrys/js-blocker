
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

extension NSTableView {

    func updateViewAfterDataChanges(rowCount: Int, colCount: Int, isDeselectRows: Bool = true) {

        if (self.numberOfRows > rowCount) {
            self.removeRows(
                at: IndexSet(rowCount ..< self.numberOfRows)
            )
        }

        if (self.numberOfRows < rowCount) {
            self.insertRows(
                at: IndexSet(self.numberOfRows ..< rowCount)
            )
        }

        if isDeselectRows == true {
            for rowNum in 0 ..< rowCount {
                self.deselectRow(rowNum)
            }
        }

        self.reloadData(
            forRowIndexes: IndexSet(0 ..< rowCount),
            columnIndexes: IndexSet(0 ..< colCount)
        )

    }

}
