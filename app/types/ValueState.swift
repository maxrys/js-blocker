
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import Foundation
import Combine

final class ValueState<T: Equatable>: ObservableObject {

    @Published public var value: T {
        willSet { if (value != newValue) { self.onChangeBefore(newValue) } }
        didSet  { if (value != oldValue) { self.onChangeAfter(value) } }
    }

    private let onChangeBefore: (T) -> Void
    private let onChangeAfter: (T) -> Void

    init(
        _ value: T,
        onChangeBefore: @escaping (T) -> Void = { _ in },
        onChangeAfter: @escaping (T) -> Void = { _ in }
    ) {
        self.value = value
        self.onChangeBefore = onChangeBefore
        self.onChangeAfter = onChangeAfter
    }

    deinit {
    }

}
