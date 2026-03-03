
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI

final class DomainsState: ObservableObject {

    static public private(set) var shared = DomainsState()

    public func getBinding<T>(_ propertyName: WritableKeyPath<DomainsState, T>) -> Binding<T> {
        var instance = self; return Binding(
            get: {             instance[keyPath: propertyName]            },
            set: { newValue in instance[keyPath: propertyName] = newValue }
        )
    }

    @Published var data: ADFetchCollection = []
    @Published var hash: Int = 0
    @Published var selectedRows: Set<Int> = []
    @Published var filterByName: String = "" {
        didSet { self.dataReload() }
    }


    var selectedRowsToNames: [String] {
        self.selectedRows.compactMap { index in
            self.data[safe: index]?.name
        }
    }

    var selectedRowsToData: ADFetchCollection {
        self.selectedRows.compactMap { index in
            self.data[safe: index]
        }
    }

    private init() { /* singleton */
        self.dataReload()
    }

    func dataReload() {
     // AllowedDomains.context.reset()
        let newData = AllowedDomains.selectAll(self.filterByName.isEmpty ? nil : self.filterByName)
        let newHash = newData.hash()
        Logger.customLog("Old Data Hash: \(self.hash)")
        Logger.customLog("New Data Hash: \(newHash)")
        if (self.hash == 0 || self.hash != newHash) {
            self.selectedRows.removeAll()
            self.data = newData
            self.hash = newHash
        }
    }

}
