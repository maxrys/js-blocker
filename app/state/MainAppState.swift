
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI

final class MainAppState: ObservableObject {

    static public private(set) var shared = MainAppState()

    public func getBinding<T>(_ propertyName: WritableKeyPath<MainAppState, T>) -> Binding<T> {
        var instance = self; return Binding(
            get: {             instance[keyPath: propertyName]            },
            set: { newValue in instance[keyPath: propertyName] = newValue }
        )
    }

    @Published var items: ADFetchCollection = []
    @Published var selectedRows: Set<Int> = []
    @Published var filterByName: String = "" {
        didSet { self.reloadIfRequired() }
    }

    private var timer: Timer.Custom!

    var selectedNames: [DomainName] {
        self.selectedRows.compactMap { index in
            self.items[safe: index]?.name
        }
    }

    var selectedItems: ADFetchCollection {
        self.selectedRows.compactMap { index in
            self.items[safe: index]
        }
    }

    private /* singleton */ init() {
        self.reloadIfRequired()
        self.timer = Timer.Custom(
            repeats: .infinity,
            delay: 2,
            onTick: self.onTimerTick
        )
    }

    private func onTimerTick(timer: Timer.Custom) {
        self.reloadIfRequired()
    }

    func reloadIfRequired() {
        let newItems = ADModel.selectAll(self.filterByName.isEmpty ? nil : self.filterByName)
        let newItemsHash = newItems.hash()
        let oldItemsHash = self.items.hash()
        Logger.customLog("Old Data Hash: \(oldItemsHash)")
        Logger.customLog("New Data Hash: \(newItemsHash)")
        if (oldItemsHash != newItemsHash) {
            let oldSelectedNames = self.selectedNames
            var newSelectedRows: Set<Int> = []
            newItems.enumerated().forEach { index, newItem in
                if (oldSelectedNames.contains(newItem.name)) {
                    newSelectedRows.insert(index)
                }
            }
            self.items = newItems
            self.selectedRows.removeAll()
            self.selectedRows = newSelectedRows
            Logger.customLog("MainAppState().reloadIfRequired()")
        }
    }

    func delete(_ names: [DomainName]) -> ExecuteResult {
        let result = ADModel.delete(names)
        if case .success = result {
            self.reloadIfRequired()
        }
        return result
    }

}
