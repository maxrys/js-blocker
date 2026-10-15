
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ShadowLine: View {

    enum Angle {
        case degrees_0
        case degrees_90
        case degrees_180
        case degrees_270
    }

    @Environment(\.colorScheme) internal var colorScheme

    private let length: CGFloat
    private let angle: Angle
    private let opacity: Double
    private let opacityDark: Double

    init(
        length: CGFloat = 5,
        angle: Angle = .degrees_0,
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
            .fill(self.Gradient())
            .frame(
                maxWidth : self.angle == .degrees_0  || self.angle == .degrees_180 ? .infinity : self.length,
                maxHeight: self.angle == .degrees_90 || self.angle == .degrees_270 ? .infinity : self.length
            )
    }
    
    private func Gradient() -> LinearGradient {
        switch self.angle {
            case .degrees_0  : return LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .top     , endPoint: .bottom)
            case .degrees_180: return LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .bottom  , endPoint: .top)
            case .degrees_90 : return LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .trailing, endPoint: .leading)
            case .degrees_270: return LinearGradient(colors: [self.colorScheme == .dark ? .black.opacity(self.opacityDark) : .black.opacity(self.opacity), Color.clear], startPoint: .leading , endPoint: .trailing)
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ShadowLine_Previews: PreviewProvider {

    static var previews: some View {
        Previewer(spacing: 0) {
            HStack(spacing: 0) {
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.1, opacityDark: 1.0)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.2, opacityDark: 0.9)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.3, opacityDark: 0.8)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.4, opacityDark: 0.7)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.5, opacityDark: 0.6)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.6, opacityDark: 0.5)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.7, opacityDark: 0.4)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.8, opacityDark: 0.3)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 0.9, opacityDark: 0.2)
                ShadowLine(length: 30, angle: .degrees_0, opacity: 1.0, opacityDark: 0.1)
            }
            HStack(spacing: 0) {
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.1, opacityDark: 1.0)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.2, opacityDark: 0.9)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.3, opacityDark: 0.8)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.4, opacityDark: 0.7)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.5, opacityDark: 0.6)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.6, opacityDark: 0.5)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.7, opacityDark: 0.4)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.8, opacityDark: 0.3)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 0.9, opacityDark: 0.2)
                ShadowLine(length: 30, angle: .degrees_180, opacity: 1.0, opacityDark: 0.1)
            }
            HStack(spacing: 0) {
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.1, opacityDark: 1.0)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.2, opacityDark: 0.9)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.3, opacityDark: 0.8)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.4, opacityDark: 0.7)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.5, opacityDark: 0.6)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.6, opacityDark: 0.5)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.7, opacityDark: 0.4)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.8, opacityDark: 0.3)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 0.9, opacityDark: 0.2)
                ShadowLine(length: 30, angle: .degrees_90, opacity: 1.0, opacityDark: 0.1)
            }.frame(height: 30)
            HStack(spacing: 0) {
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.1, opacityDark: 1.0)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.2, opacityDark: 0.9)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.3, opacityDark: 0.8)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.4, opacityDark: 0.7)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.5, opacityDark: 0.6)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.6, opacityDark: 0.5)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.7, opacityDark: 0.4)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.8, opacityDark: 0.3)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 0.9, opacityDark: 0.2)
                ShadowLine(length: 30, angle: .degrees_270, opacity: 1.0, opacityDark: 0.1)
            }.frame(height: 30)
        }.frame(width: 300)
    }

}
