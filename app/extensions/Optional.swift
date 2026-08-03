
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

extension Optional {

    func ifNil<T>(
        defaultValue: T,
        _ ifNotNilClosure: (Wrapped) -> T
    ) -> T {
        switch self {
            case .some(let unwrappedValue): return ifNotNilClosure(unwrappedValue)
            case .none                    : return defaultValue
        }
    }

}
