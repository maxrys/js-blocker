
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import os
import SwiftUI

struct ProgressSimple: View {

    @Environment(\.colorScheme) private var colorScheme

    private let value: Double
    private let height: CGFloat
    private let radius: Double

    init(value: Double, height: CGFloat = 10, radius: CGFloat = 10) {
        self.value = value
        self.height = height
        self.radius = radius
    }

    var body: some View {
        Color.clear
            .frame(height: self.height)
            .background( self.IndicatorView() )
            .background( self.BackgroundView() )
    }

    @ViewBuilder func IndicatorView() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width * self.value.fixBounds(max: 1.0)
            RoundedRectangle(cornerRadius: self.radius)
                .fill(Color.progressSimple.indicator)
                .frame(width: width)
        }.padding(2)
    }

    @ViewBuilder func BackgroundView() -> some View {
        RoundedRectangle(cornerRadius: self.radius)
            .fill(Color.progressSimple.background)
            .overlayPolyfill {
                RoundedRectangle(cornerRadius: self.radius)
                    .stroke(Color.progressSimple.border, lineWidth: 2)
            }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ProgressSimple_Previews: PreviewProvider {
    static public var previews: some View {
        Previewer {
            VStack(spacing: 5) {
                ForEach(Array(stride(from: -0.1, through: 1.1, by: 0.1)), id: \.self) { value in
                    ProgressSimple(value: value)
                }
            }.padding(20).frame(width: 200)
        }
    }
}

