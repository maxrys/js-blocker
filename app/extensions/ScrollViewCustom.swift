
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI
import Combine

private struct SizeKey: PreferenceKey {
    static var defaultValue = CGSize(width: 0, height: 0)
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ScrollViewCustom<Content: View>: View {

    @State private var size = CGSize(width: 0, height: 0)

    private var isUndersize: Bool {
        self.size.width  <= self.limits.width &&
        self.size.height <= self.limits.height
    }

    private let axis: Axis.Set
    private let limits: CGSize
    private let content: () -> Content

    init(
        axis: Axis.Set,
        scrollAfter limits: CGSize,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.axis = axis
        self.limits = limits
        self.content = content
    }

    public var body: some View {
        if (self.isUndersize)     { self.FinalContentView() } else {
            ScrollView(self.axis) { self.FinalContentView() }.frame(
                maxWidth : self.limits.width,
                maxHeight: self.limits.height
            )
        }
    }

    @ViewBuilder func FinalContentView() -> some View {
        ZStack {
            Color.clear.background(
                GeometryReader { geometry in
                    Color.clear.preference(key: SizeKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizeKey.self) { size in
                self.size = size
            }
            self.content()
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ScrollViewCustom_Previews: PreviewProvider {

    struct ViewWithState: View {

        final class DemoState: ObservableObject {
            static public private(set) var shared = DemoState()
            @Published var count: UInt = 0
        }

        struct DemoView: View {
            @StateObject private var state = DemoState.shared
            public var body: some View {
                VStack(spacing: 10) {
                    ForEach(0 ..< Int(self.state.count), id: \.self) { i in
                        Text("Item \(i)")
                    }
                }
            }
        }

        @ObservedObject static private var previewMode = ValueState<UInt>(0) { value in
            switch value {
                case 0: DemoState.shared.count =  0
                case 1: DemoState.shared.count =  5
                case 2: DemoState.shared.count = 10
                case 3: DemoState.shared.count = 20
                case 4: DemoState.shared.count = 30
                default: break
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                ScrollViewCustom(axis: .vertical, scrollAfter: .init(width: 200, height: 200)) {
                    DemoView()
                }.background(Color.gray)
                PreviewMode(
                    title: "count",
                    state: Self.previewMode,
                    modes: ["0", "5", "10", "20", "30"]
                )
            }.frame(
                width: 200, height: 280
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}
