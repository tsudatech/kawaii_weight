//
//  Sparkline.swift
//  kawaii_taiju_kanri
//
//  ウィジェット用の小さな折れ線
//

import SwiftUI

struct Sparkline: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard values.count > 1, let lo = values.min(), let hi = values.max() else { return p }
        for (i, v) in values.enumerated() {
            let x = rect.minX + rect.width * Double(i) / Double(values.count - 1)
            let ratio = hi == lo ? 0.5 : (v - lo) / (hi - lo)
            let y = rect.maxY - rect.height * ratio
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        return p
    }
}
