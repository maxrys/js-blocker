
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct TableCustom_HeadCell: View {

    let size: GridItem.Size
    let spacing: CGFloat?
    let alignment: Alignment?
    let content: any View

    init(
        size: GridItem.Size = .flexible(),
        spacing: CGFloat? = nil,
        alignment: Alignment? = nil,
        @ViewBuilder content: () -> any View
    ) {
        self.size = size
        self.spacing = spacing
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        AnyView(self.content)
    }

}
