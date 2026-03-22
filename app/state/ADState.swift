
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI

final class ADState: ObservableObject {

    static public private(set) var shared = ADState()

    public func getBinding<T>(_ propertyName: WritableKeyPath<ADState, T>) -> Binding<T> {
        var instance = self; return Binding(
            get: {             instance[keyPath: propertyName]            },
            set: { newValue in instance[keyPath: propertyName] = newValue }
        )
    }

    @Published var items: ADFetchCollection = []
    @Published var selectedRows: Set<Int> = []
    @Published var filterByName: String = "" {
        didSet { self.reload() }
    }


    var selectedRowsToNames: [String] {
        self.selectedRows.compactMap { index in
            self.items[safe: index]?.name
        }
    }

    var selectedRowsToData: ADFetchCollection {
        self.selectedRows.compactMap { index in
            self.items[safe: index]
        }
    }

    private init() { /* singleton */
        self.reload()
    }

    func reload() {
        let newItems = ADModel.selectAll(self.filterByName.isEmpty ? nil : self.filterByName)
        let newItemsHash = newItems.hash()
        let oldItemsHash = self.items.hash()
        Logger.customLog("Old Data Hash: \(oldItemsHash)")
        Logger.customLog("New Data Hash: \(newItemsHash)")
        if (oldItemsHash != newItemsHash) {
            self.items = newItems
            self.selectedRows.removeAll()
            Logger.customLog("\nADState().reload()")
        }
    }

    func delete(_ names: [String]) -> ExecuteResult {
        let result = ADModel.delete(names)
        if case .success = result {
            self.reload()
        }
        return result
    }

}
