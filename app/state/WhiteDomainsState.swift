
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI

final class WhiteDomainsState: ObservableObject {

    static public private(set) var shared = WhiteDomainsState()

    public func getBinding<T>(_ propertyName: WritableKeyPath<WhiteDomainsState, T>) -> Binding<T> {
        var instance = self; return Binding(
            get: {             instance[keyPath: propertyName]            },
            set: { newValue in instance[keyPath: propertyName] = newValue }
        )
    }

    @Published var data: [WhiteDomains] = []
    @Published var hash: Int = 0
    @Published var selectedRows: Set<Int> = []
    @Published var filterByName: String = "" {
        didSet { self.dataReload() }
    }


    var selectedRowsToPrimaryKeys: [String] {
        self.selectedRows.compactMap { index in
            self.data[safe: index]?.name
        }
    }

    var selectedRowsToData: [WhiteDomains] {
        self.selectedRows.compactMap { index in
            self.data[safe: index]
        }
    }

    private init() { /* singleton */
        self.dataReload()
    }

    func dataReload() {
     // WhiteDomains.context.reset()
        let newData = WhiteDomains.selectAll(self.filterByName.isEmpty ? nil : self.filterByName)
        let newHash = WhiteDomains.hashOfSet(newData)
        Logger.customLog("Old Data Hash: \(self.hash)")
        Logger.customLog("New Data Hash: \(newHash)")
        if (self.hash == 0 || self.hash != newHash) {
            self.selectedRows.removeAll()
            self.data = newData
            self.hash = newHash
        }
    }

}
