
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SwiftUI
import SafariServices

final class MainAppState: ObservableObject {

    static let TIMER_DELAY: Double = 5.0

    static public private(set) var shared = MainAppState()

    public func getBinding<T>(_ propertyName: WritableKeyPath<MainAppState, T>) -> Binding<T> {
        var instance = self; return Binding(
            get: {             instance[keyPath: propertyName]            },
            set: { newValue in instance[keyPath: propertyName] = newValue }
        )
    }

    @Published var items: ADFetchCollection = []
    @Published var itemsVersion: Int64? = nil
    @Published var selectedRows: Set<Int> = []
    @Published var filterByName: String = "" {
        didSet { self.itemsReload() }
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
        self.itemsInit()
        self.timer = Timer.Custom(
            repeats: .infinity,
            delay: Self.TIMER_DELAY,
            onTick: self.onTimerTick
        )
    }

    private func itemsInit() {
        self.items = ADModel.selectAll()
        self.itemsVersion = EntityVersions.versionGet(ADModel.stringName)
    }

    public func itemsReload(_ newItemsVersion: Int64? = nil) {
        let oldSelectedNames = self.selectedNames
        self.items = ADModel.selectAll(self.filterByName.isEmpty ? nil : self.filterByName)
        self.itemsVersion = newItemsVersion ?? EntityVersions.versionGet(ADModel.stringName)
        if (!oldSelectedNames.isEmpty) {
            self.selectedRows = self.items.enumerated().reduce(into: Set<Int>(), { result, newPair in
                if (oldSelectedNames.contains(newPair.element.name)) {
                    result.insert(newPair.offset)
                }
            })
        }
    }

    private func onTimerTick(timer: Timer.Custom) {
        _ = ADModel.sanitize()
        let newItemsVersion = EntityVersions.versionGet(ADModel.stringName)
        if (self.itemsVersion != newItemsVersion) {
            self.itemsReload(newItemsVersion)
        }
    }

    func delete(_ names: [DomainName]) -> ExecuteResult {
        let result = ADModel.delete(names)
        if case .success = result {
            self.selectedRows = []
            self.itemsReload()
            if (WITH_RULES_EXTENSION) {
                SFSafariApplication.reloadRules()
            }
        }
        return result
    }

}
