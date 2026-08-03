
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

public enum Flexibility {
    case none
    case size(CGFloat)
    case infinity
}

extension View {

    @ViewBuilder func flexibility(_ value: Flexibility = .none) -> some View {
        switch value {
            case .size(let size): self.frame(width: size)
            case .infinity      : self.frame(maxWidth: .infinity)
            case .none          : self
        }
    }

    @ViewBuilder func foregroundPolyfill(_ color: Color) -> some View {
        if #available(macOS 14.0, iOS 17.0, *) { self.foregroundStyle(color) }
        else                                   { self.foregroundColor(color) }
    }

    @ViewBuilder func onKeyPressForSelectAll(action: @escaping () -> Void) -> some View {
        if #available(macOS 14.0, *) {
            self.onKeyPress(phases: .down) { press in
                if (press.modifiers == [.command] &&
                    press.characters.contains("a")) { action() }
                return .handled
            }
        } else { self }
    }

    @ViewBuilder func pointerStyleLinkPolyfill(_ isEnabled: Bool = true) -> some View {
        if (isEnabled) {
            self.onHover { isInView in
                if (isInView) { NSCursor.pointingHand.push() }
                else          { NSCursor.pop() }
            }
        } else {
            self
        }
    }

    @ViewBuilder func focusEffect<S>(_ shape: S) -> some View where S: Shape {
        if #available(macOS 12.0, *) {
            self.contentShape(.focusEffect, shape)
        } else {
            self
        }
    }

    @ViewBuilder func overlayPolyfill<Content: View>(
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            self
            content()
        }
    }

    @ViewBuilder func ignoresSafeArea(isIgnore: Bool = true, _ regions: SafeAreaRegions = .all, edges: Edge.Set = .all) -> some View {
        if (isIgnore)
             { self.ignoresSafeArea(regions, edges: edges) }
        else { self }
    }

    @ViewBuilder func onAppBecomeBackground(_ action: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification),
            perform: { _ in
                action()
            }
        )
    }

    @ViewBuilder func onAppBecomeForeground(_ action: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification),
            perform: { _ in
                action()
            }
        )
    }

    @ViewBuilder func onWinBecomeForeground(_ action: @escaping (NSWindow) -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification),
            perform: { info in
                if let window = info.object as? NSWindow {
                    action(window)
                }
            }
        )
    }

    @ViewBuilder func onWinBecomeBackground(_ action: @escaping (NSWindow) -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: NSWindow.didResignMainNotification),
            perform: { info in
                if let window = info.object as? NSWindow {
                    action(window)
                }
            }
        )
    }

}

extension View {

    @ViewBuilder func windowChamelionBackground(windowID: String, colorScheme: ColorScheme, isIgnoreSafeArea: Bool = true) -> some View {
        self.ignoresSafeArea(
                isIgnore: isIgnoreSafeArea
            )
            .background(
                ChamelionBackground(
                    colorScheme: colorScheme
                )
            )
            .onAppear {
                if let window = NSWindow.get(windowID) {
                    window.backgroundColor = .clear
                    window.alphaValue = 1.0
                }
            }
    }

}

struct ChamelionBackground: View {

    let colorScheme: ColorScheme

    public var body: some View {
        if #available(macOS 12.0, *) {
            if (colorScheme == .dark)
                 { Rectangle().fill(.ultraThickMaterial) }
            else { Rectangle().fill(.ultraThickMaterial).overlayPolyfill { Color.NS[\.windowBackgroundColor].opacity(0.7) } }
        } else {
            Color.NS[\.windowBackgroundColor]
        }
    }

}
