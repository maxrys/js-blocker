
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

private struct GeometrySizePreferenceKey: PreferenceKey {

    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }

}

enum GeometryReaderType {

    case inside

    case outside(
        axes: Axis.Set,
        alignment: Alignment
    )

}

struct GeometryReaderPolyfill<Content: View>: View {

    @Binding private var sizeBinding: CGSize
    @State private var size: CGSize = .zero

    private let type: GeometryReaderType
    private let content: (CGSize) -> Content

    init(
        type: GeometryReaderType,
        size binding: Binding<CGSize> = .constant(.zero),
        @ViewBuilder content: @escaping (CGSize) -> Content,
    ) {
        self.type = type
        self._sizeBinding = binding
        self.content = content
    }

    public var body: some View {
        switch (self.type) {
            case .inside:
                self.content(self.size)
                    .overlay (
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: GeometrySizePreferenceKey.self,
                                    value: geometry.size
                                )
                        }
                    )
                    .onPreferenceChange(GeometrySizePreferenceKey.self) { newSize in
                        guard newSize != self.size else { return }
                        self.size        = newSize
                        self.sizeBinding = newSize
                    }
            case .outside(let axes, let alignment):
                ZStack(alignment: alignment) {
                    Group {
                        if      (axes.contains([.horizontal, .vertical])) { Color.clear }
                        else if (axes.contains([.horizontal           ])) { Color.clear.frame(height: 0) }
                        else if (axes.contains([             .vertical])) { Color.clear.frame(width : 0) }
                    }.overlay (
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: GeometrySizePreferenceKey.self,
                                    value: geometry.size
                                )
                        }
                    )
                    .onPreferenceChange(GeometrySizePreferenceKey.self) { newSize in
                        guard newSize != self.size else { return }
                        self.size        = newSize
                        self.sizeBinding = newSize
                    }
                    self.content(self.size)
                }
        }
    }

}

private struct GeometryChangeModifier: ViewModifier {

    let type: GeometryReaderType

    @Binding var size: CGSize

    func body(content: Content) -> some View {
        GeometryReaderPolyfill(type: self.type, size: self.$size) { _ in
            content
        }
    }

}

extension View {

    func onGeometryChangePolyfill(type: GeometryReaderType, size: Binding<CGSize>) -> some View {
        modifier(
            GeometryChangeModifier(
                type: type,
                size: size
            )
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct GeometryReaderOutside_Previews: PreviewProvider {

    struct ViewWithState: View {

        @State private var size1: CGSize = .zero
        @State private var size2: CGSize = .zero
        @State private var isBig: Bool = false

        var body: some View {
            HStack {
                GeometryReaderPolyfill(type: .outside(axes: .vertical, alignment: .center)) { size in
                    Button { self.isBig.toggle() } label: {
                        self.MarkerView()
                            .frame(width: 100, height: self.isBig ? 200 : 100)
                            .overlay (
                                Text("\(size.height)")
                                    .foregroundColor(.white)
                            )
                    }.buttonStyle(.plain)
                }
                GeometryReaderPolyfill(type: .outside(axes: .vertical, alignment: .center), size: self.$size1) { _ in
                    Button { self.isBig.toggle() } label: {
                        self.MarkerView()
                            .frame(width: 100, height: self.isBig ? 200 : 100)
                            .overlay (
                                Text("\(self.size1.height)")
                                    .foregroundColor(.white)
                            )
                    }.buttonStyle(.plain)
                }
                Button { self.isBig.toggle() } label: {
                    self.MarkerView()
                        .frame(width: 100, height: self.isBig ? 200 : 100)
                        .overlay (
                            Text("\(self.size2.height)")
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
                .onGeometryChangePolyfill(type: .outside(axes: .vertical, alignment: .center), size: self.$size2)
            }

        }

        @ViewBuilder private func MarkerView() -> some View {
            Rectangle()
                .fill(.blue)
        }

    }

    static var previews: some View {
        ViewWithState()
            .frame(height: 300)
    }

}

struct GeometryReaderInside_Previews: PreviewProvider {

    struct ViewWithState: View {

        @State private var size1: CGSize = .zero
        @State private var size2: CGSize = .zero
        @State private var isBig: Bool = false

        var body: some View {
            HStack {
                GeometryReaderPolyfill(type: .inside) { size in
                    Button { self.isBig.toggle() } label: {
                        self.MarkerView()
                            .frame(width: 100, height: self.isBig ? 200 : 100)
                            .overlay (
                                Text("\(size.height)")
                                    .foregroundColor(.white)
                            )
                    }.buttonStyle(.plain)
                }
                GeometryReaderPolyfill(type: .inside, size: self.$size1) { _ in
                    Button { self.isBig.toggle() } label: {
                        self.MarkerView()
                            .frame(width: 100, height: self.isBig ? 200 : 100)
                            .overlay (
                                Text("\(self.size1.height)")
                                    .foregroundColor(.white)
                            )
                    }.buttonStyle(.plain)
                }
                Button { self.isBig.toggle() } label: {
                    self.MarkerView()
                        .frame(width: 100, height: self.isBig ? 200 : 100)
                        .overlay (
                            Text("\(self.size2.height)")
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
                .onGeometryChangePolyfill(type: .inside, size: self.$size2)
            }
        }

        @ViewBuilder private func MarkerView() -> some View {
            Rectangle()
                .fill(.blue)
        }

    }

    static var previews: some View {
        ViewWithState()
            .frame(height: 300)
    }

}
