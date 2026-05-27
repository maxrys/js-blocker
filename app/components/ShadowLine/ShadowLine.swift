
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ShadowLine: View {

    enum Angle {
        case   `0_degrees`
        case  `90_degrees`
        case `180_degrees`
        case `270_degrees`
    }

    @Environment(\.colorScheme) internal var colorScheme

    private let length: CGFloat
    private let angle: Angle
    private let opacity: Double
    private let opacityDark: Double

    init(
        length: CGFloat = 5,
        angle: Angle = .`0_degrees`,
        opacity: Double = 0.2,
        opacityDark: Double = 0.9
    ) {
        self.length      = length
        self.angle       = angle
        self.opacity     = opacity
        self.opacityDark = opacityDark
    }

    public var body: some View {
        Rectangle()
            .fill({
                switch self.angle {
                    case   .`0_degrees`: LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .top     , endPoint: .bottom)
                    case .`180_degrees`: LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .bottom  , endPoint: .top)
                    case  .`90_degrees`: LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .trailing, endPoint: .leading)
                    case .`270_degrees`: LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .leading , endPoint: .trailing)
                }
            }())
            .frame(
                maxWidth : self.angle ==  .`0_degrees` || self.angle == .`180_degrees` ? .infinity : self.length,
                maxHeight: self.angle == .`90_degrees` || self.angle == .`270_degrees` ? .infinity : self.length
            )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

#Preview {
    Previewer(isHorizontal: false, spacing: 0) {
        HStack (spacing: 0) {
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.1, opacityDark: 1.0)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.2, opacityDark: 0.9)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.3, opacityDark: 0.8)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.4, opacityDark: 0.7)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.5, opacityDark: 0.6)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.6, opacityDark: 0.5)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.7, opacityDark: 0.4)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.8, opacityDark: 0.3)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 0.9, opacityDark: 0.2)
            ShadowLine(length: 30, angle: .`0_degrees`, opacity: 1.0, opacityDark: 0.1)
        }
        HStack (spacing: 0) {
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.1, opacityDark: 1.0)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.2, opacityDark: 0.9)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.3, opacityDark: 0.8)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.4, opacityDark: 0.7)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.5, opacityDark: 0.6)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.6, opacityDark: 0.5)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.7, opacityDark: 0.4)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.8, opacityDark: 0.3)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 0.9, opacityDark: 0.2)
            ShadowLine(length: 30, angle: .`90_degrees`, opacity: 1.0, opacityDark: 0.1)
        }
        HStack (spacing: 0) {
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.1, opacityDark: 1.0)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.2, opacityDark: 0.9)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.3, opacityDark: 0.8)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.4, opacityDark: 0.7)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.5, opacityDark: 0.6)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.6, opacityDark: 0.5)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.7, opacityDark: 0.4)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.8, opacityDark: 0.3)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 0.9, opacityDark: 0.2)
            ShadowLine(length: 30, angle: .`180_degrees`, opacity: 1.0, opacityDark: 0.1)
        }
        HStack (spacing: 0) {
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.1, opacityDark: 1.0)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.2, opacityDark: 0.9)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.3, opacityDark: 0.8)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.4, opacityDark: 0.7)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.5, opacityDark: 0.6)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.6, opacityDark: 0.5)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.7, opacityDark: 0.4)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.8, opacityDark: 0.3)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 0.9, opacityDark: 0.2)
            ShadowLine(length: 30, angle: .`270_degrees`, opacity: 1.0, opacityDark: 0.1)
        }
    }.frame(width: 300)
}
