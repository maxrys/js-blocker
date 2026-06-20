
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

infix operator ≈≈ : ComparisonPrecedence

struct Message: Hashable {

    let type: MessageType
    let title: String
    let description: String
    let isClosable: Bool
    let startedAt: CFTimeInterval
    let expiresAt: CFTimeInterval?

    init(
        type: MessageType,
        title: String,
        description: String = "",
        isClosable: Bool = false,
        expiresAt: CFTimeInterval? = nil
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.isClosable = isClosable
        self.expiresAt = expiresAt
        self.startedAt = CACurrentMediaTime()
    }

    static func ≈≈ (lhs: Self, rhs: Self) -> Bool {
        lhs.type        == rhs.type  &&
        lhs.title       == rhs.title &&
        lhs.description == rhs.description
    }

    var status: MessageStatus {
        if let expiresAt = self.expiresAt {
            if (CACurrentMediaTime() > expiresAt) {
                return .expired
            } else {
                let maxValue = expiresAt            - self.startedAt
                let curValue = CACurrentMediaTime() - self.startedAt
                guard maxValue > 0 else { return .inProgress(0) }
                return .inProgress(
                    (curValue / maxValue).fixBounds(
                        min: 0.0,
                        max: 1.0
                    )
                )
            }
        }
        return .persistent
    }

}
