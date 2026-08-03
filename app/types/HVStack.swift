
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct HVStack<Content: View>: View {

    private let axis: Axis
    private let spacing: CGFloat
    private let content: () -> Content

    init(
        axis: Axis,
        spacing: CGFloat = 10,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        switch self.axis {
            case .horizontal: HStack(spacing: self.spacing) { self.content() }
            case .vertical  : VStack(spacing: self.spacing) { self.content() }
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

#Preview {
    VStack(spacing: 10) {

        HVStack(axis: .vertical) {
            Text("1").background(Color.yellow)
            Text("2").background(Color.yellow)
            Text("3").background(Color.yellow)
        }.frame(width: 100, height: 100).background(Color.white)

        HVStack(axis: .horizontal) {
            Text("1").background(Color.yellow)
            Text("2").background(Color.yellow)
            Text("3").background(Color.yellow)
        }.frame(width: 100, height: 100).background(Color.white)

    }.padding(10).background(Color.black)
}
