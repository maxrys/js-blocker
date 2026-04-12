
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import Combine

final class ValueState<T>: ObservableObject {

    @Published var value: T

    init(_ value: T) {
        self.value = value
    }

}
