
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI
import Combine

struct PreviewMode: View {

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

struct PreviewMode_Previews: PreviewProvider {

    struct ViewWithState: View {

        static let DEMO_VALUE_X_0 = "1"
        static let DEMO_VALUE_X_1 = "2"
        static let DEMO_VALUE_X_2 = "3"

        static let DEMO_VALUE_Y_0 = "a"
        static let DEMO_VALUE_Y_1 = "b"
        static let DEMO_VALUE_Y_2 = "c"

        static let DEMO_VALUE_Z_0 = "q"
        static let DEMO_VALUE_Z_1 = "w"
        static let DEMO_VALUE_Z_2 = "e"

        final class DemoState: ObservableObject {
            static public private(set) var shared = DemoState()
            @Published var x: String = DEMO_VALUE_X_0
            @Published var y: String = DEMO_VALUE_Y_0
            @Published var z: String = DEMO_VALUE_Z_0
        }

        struct DemoView: View {
            @StateObject private var state = DemoState.shared
            public var body: some View {
                VStack(spacing: 10) {
                    Text("x = \(self.state.x)")
                    Text("y = \(self.state.y)")
                    Text("z = \(self.state.z)")
                }
            }
        }

        @ObservedObject static private var previewModeX = ValueState<UInt>(0) { value in
            switch value {
                case 0: DemoState.shared.x = DEMO_VALUE_X_0
                case 1: DemoState.shared.x = DEMO_VALUE_X_1
                case 2: DemoState.shared.x = DEMO_VALUE_X_2
                default: break
            }
        }

        @ObservedObject static private var previewModeY = ValueState<UInt>(0) { value in
            switch value {
                case 0: DemoState.shared.y = DEMO_VALUE_Y_0
                case 1: DemoState.shared.y = DEMO_VALUE_Y_1
                case 2: DemoState.shared.y = DEMO_VALUE_Y_2
                default: break
            }
        }

        @ObservedObject static private var previewModeZ = ValueState<UInt>(0) { value in
            switch value {
                case 0: DemoState.shared.z = DEMO_VALUE_Z_0
                case 1: DemoState.shared.z = DEMO_VALUE_Z_1
                case 2: DemoState.shared.z = DEMO_VALUE_Z_2
                default: break
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                DemoView().padding(30)
                Spacer().frame(minWidth: 0)
                PreviewMode(
                    title: "value X",
                    state: Self.previewModeX,
                    modes: [
                        Self.DEMO_VALUE_X_0,
                        Self.DEMO_VALUE_X_1,
                        Self.DEMO_VALUE_X_2,
                    ]
                )
                PreviewMode(
                    title: "value Y",
                    state: Self.previewModeY,
                    modes: [
                        Self.DEMO_VALUE_Y_0,
                        Self.DEMO_VALUE_Y_1,
                        Self.DEMO_VALUE_Y_2,
                    ]
                )
                PreviewMode(
                    title: "value Z",
                    state: Self.previewModeZ,
                    modes: [
                        Self.DEMO_VALUE_Z_0,
                        Self.DEMO_VALUE_Z_1,
                        Self.DEMO_VALUE_Z_2,
                    ]
                )
            }.frame(
                width: 200, height: 380
            )
        }

    }

    static var previews: some View {
        ViewWithState()
    }

}

