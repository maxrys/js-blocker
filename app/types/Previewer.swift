
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct Previewer<Content: View>: View {

    private let isHorizontal: Bool
    private let spacing: CGFloat
    private let padding: CGFloat
    private let content: () -> Content

    init(
        isHorizontal: Bool = false,
        spacing: CGFloat = 20,
        padding: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isHorizontal = isHorizontal
        self.spacing = spacing
        self.padding = padding
        self.content = content
    }

    public var body: some View {
        Group {
            if (self.isHorizontal) {
                HStack(spacing: 0) {
                    VStack(spacing: self.spacing) { content() }
                        .padding(self.padding)
                        .background(Color.NS[\.windowBackgroundColor])
                        .environment(\.colorScheme, .light)
                    VStack(spacing: self.spacing) { content() }
                        .padding(self.padding)
                        .background(Color.NS[\.windowBackgroundColor])
                        .environment(\.colorScheme, .dark)
                }
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: self.spacing) { content() }
                        .padding(self.padding)
                        .background(Color.NS[\.windowBackgroundColor])
                        .environment(\.colorScheme, .light)
                    VStack(spacing: self.spacing) { content() }
                        .padding(self.padding)
                        .background(Color.NS[\.windowBackgroundColor])
                        .environment(\.colorScheme, .dark)
                }
            }
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

#Preview {
    Previewer(isHorizontal: false, spacing: 5, padding: 20) {
        Text("Previewer element 1")
        Text("Previewer element 2")
        Text("Previewer element 3")
    }
}
