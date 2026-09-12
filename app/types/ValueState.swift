
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import Foundation
import Combine

final class ValueState<T>: ObservableObject {

    @Published public var value: T {
        willSet { self.onChange(newValue) }
    }

    private let onChange: (T) -> Void

    init(_ value: T, _ onChange: @escaping (T) -> Void = { _ in }) {
        self.value    = value
        self.onChange = onChange
    }

}
