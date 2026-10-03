
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ButtonRectangle: View {

    @Environment(\.isEnabled) private var isEnabled

    private var colorIcon: Color {
        if (self.isActive)
             { return Color.buttonRectangle.iconActive }
        else { return Color.buttonRectangle.icon }
    }

    private var colorBorder: Color {
        if (self.isActive)
             { return Color.buttonRectangle.borderActive }
        else { return Color.buttonRectangle.border }
    }

    private var colorBackground: Color {
        Color.buttonRectangle.background
    }

    private let isActive: Bool
    private let shape = RoundedRectangle(cornerRadius: 12)
    private let icon: Image
    private let iconSize: CGFloat
    private let iconOffset: CGPoint
    private let onClick: () -> Void

    init(
        isActive: Bool,
        icon: Image,
        iconSize: CGFloat,
        iconOffset: CGPoint = CGPoint(x: 0, y: 0),
        onClick: @escaping () -> Void
    ) {
        self.isActive = isActive
        self.icon = icon
        self.iconSize = iconSize
        self.iconOffset = iconOffset
        self.onClick = onClick
    }

    public var body: some View {
        Button {
            self.onClick()
        } label: {
            self.shape
                .stroke(self.colorBorder, lineWidth: 2)
                .background(self.shape.fill(self.colorBackground))
                .frame(width: 36, height: 36)
                .overlayPolyfill {
                    self.icon
                        .font(.system(size: self.iconSize))
                        .offset(
                            x: self.iconOffset.x,
                            y: self.iconOffset.y
                        )
                }
            .foregroundPolyfill(self.colorIcon)
            .contentShape(self.shape)
            .focusEffect (self.shape)
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill(self.isEnabled)
        .disabled(!self.isEnabled)
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ButtonRectangle_Previews: PreviewProvider {
    struct ViewWithState: View {
        @State private var isActive: Bool = false
        public var body: some View {
            Previewer(padding: 20) {
                ButtonRectangle(
                    isActive: self.isActive,
                    icon: Image(systemName: "globe"),
                    iconSize: 24,
                    onClick: {
                        self.isActive.toggle()
                    }
                )
            }
        }
    }
    static public var previews: some View {
        self.ViewWithState()
    }
}
