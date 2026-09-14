
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct Previewer<Content: View>: View {

    private let axis: Axis
    private let spacing: CGFloat
    private let padding: CGFloat
    private let content: () -> Content

    init(
        axis: Axis = .vertical,
        spacing: CGFloat = 20,
        padding: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.spacing = spacing
        self.padding = padding
        self.content = content
    }

    public var body: some View {
        HVStack(axis: self.axis, spacing: 0) {
            VStack(spacing: self.spacing) { self.content() }
                .padding(self.padding)
                .background(Color.NS[\.windowBackgroundColor])
                .environment(\.colorScheme, .light)
            VStack(spacing: self.spacing) { self.content() }
                .padding(self.padding)
                .background(Color.NS[\.windowBackgroundColor])
                .environment(\.colorScheme, .dark)
        }
    }

}



struct PreviewModeSelector: View {

    @ObservedObject private var state: ValueState<UInt>
    private let title:  String?
    private let modes: [String]

    init(title: String? = nil, state: ValueState<UInt>, modes: [String]) {
        self.title = title
        self.state = state
        self.modes = modes
    }

    var body: some View {
        VStack(spacing: 10) {
            if let title = self.title {
                Text(title)
                    .font(.headline)
            }
            HStack(spacing: 0) {
                ForEach(self.modes.indices, id: \.self) { index in
                    self.ButtonView(
                        index: UInt(index)
                    )
                }
            }
            .padding(5)
            .background(Color.black.opacity(0.05))
            .clipShape(Capsule())
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    @ViewBuilder func ButtonView(index: UInt) -> some View {
        Button {
            self.state.value = index
        } label: {
            let isActive = self.state.value == index
            Text(self.modes[Int(index)])
                .padding(.horizontal, 10)
                .padding(.vertical  ,  5)
                .foregroundPolyfill(
                    isActive ?
                        Color.white :
                        Color.black
                )
                .background(
                    Capsule()
                        .fill(isActive ?
                            Color.blue :
                            Color.clear
                        )
                )
                .clipShape   (Capsule())
                .contentShape(Capsule())
                .focusEffect (Capsule())
        }
        .focusable(false)
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

#Preview {
    Previewer(axis: .vertical, spacing: 5, padding: 20) {
        Text("Previewer element 1")
        Text("Previewer element 2")
        Text("Previewer element 3")
    }
}
