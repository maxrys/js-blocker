
import SafariServices

extension NSTableView {

    func relateWithController(delegate: NSTableViewDelegate, dataSource: NSTableViewDataSource) {
        self.delegate   = delegate
        self.dataSource = dataSource
    }

    func updateViewAfterDataChanges(outlet: NSTableView, rowCount: Int, colCount: Int, isDeselectRows: Bool = true) {

        if (outlet.numberOfRows > rowCount) {
            outlet.removeRows(
                at: IndexSet(rowCount..<outlet.numberOfRows)
            )
        }

        if (outlet.numberOfRows < rowCount) {
            outlet.insertRows(
                at: IndexSet(outlet.numberOfRows..<rowCount)
            )
        }

        if isDeselectRows == true {
            for rowNum in 0..<rowCount {
                outlet.deselectRow(rowNum)
            }
        }

        outlet.reloadData(
            forRowIndexes: IndexSet(0..<rowCount),
            columnIndexes: IndexSet(0..<colCount)
        )
    }

}
