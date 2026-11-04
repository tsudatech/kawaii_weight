//
//  RewardOverlay.swift
//  kawaii_taiju_kanri
//
//  ごほうびのお祝い（紙吹雪つき）
//

import SwiftUI

struct RewardOverlay: View {
    let badge: Badge
    @EnvironmentObject private var store: WeightStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    var body: some View {
        ZStack {
            Color(hex: 0x2B1C12).opacity(0.45)
                .ignoresSafeArea()
            if !reduceMotion {
                ConfettiView().allowsHitTesting(false).ignoresSafeArea()
            }
            // .rwCard
            VStack(spacing: 0) {
                Text(L("ごほうびゲット！")).font(.ui(12, .black)).tracking(1.44).foregroundStyle(Color(hex: 0xB88330))
                BalancedLines(text: badge.title, font: .ui(26, .black), size: 26, lineHeight: LineMetrics.ui)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                CharacterView(asset: badge.mood.largeAsset, size: 170, breathe: false)
                    .padding(.top, 4)
                Text((store.characterName.isEmpty ? "" : "\(store.characterName)：") + badge.message)
                    .font(.ui(14))
                    .lineHeight(1.6, size: 14)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 6)
                if let gift = badge.gift {
                    Text(gift)
                        .font(.ui(12))
                        .foregroundStyle(Color(hex: 0x8A6420))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8).padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0xFFF3D9)))
                        .padding(.top, 12)
                }
                Button(L("ありがとう！"), action: close)
                    .buttonStyle(.primary)
                    .padding(.top, 14)
            }
            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 22)
            .frame(maxWidth: 310)
            .background(RoundedRectangle(cornerRadius: 32).fill(Palette.paper))
            .scaleEffect(shown ? 1 : 0.7)
            .padding(24)
        }
        .onAppear {
            withAnimation(.timingCurve(0.3, 1.6, 0.5, 1, duration: 0.45)) { shown = true }
        }
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.25)) { store.celebrating = nil }
    }
}

/// 紙吹雪（約3秒）
struct ConfettiView: View {
    private struct Piece {
        let x0: Double, vx: Double, vy: Double, size: Double, spin: Double, color: Color, round: Bool
    }

    @State private var start = Date()
    // onAppear で作ると Canvas に届かないことがあるので、はじめから作っておく
    @State private var pieces = Self.makePieces()

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSince(start) * 60
                guard t < 200 else { return }
                for p in pieces {
                    let x = size.width / 2 + p.x0 + p.vx * t * 0.99
                    let y = size.height * 0.38 + p.vy * t + 0.14 * t * t
                    var c = ctx
                    c.translateBy(x: x, y: y)
                    c.rotate(by: .radians(p.spin * t))
                    let rect = p.round
                        ? CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size)
                        : CGRect(x: -p.size / 2, y: -p.size / 4, width: p.size, height: p.size / 2)
                    c.fill(p.round ? Path(ellipseIn: rect) : Path(rect), with: .color(p.color))
                }
            }
        }
        .onAppear { start = Date() }
    }

    private static func makePieces() -> [Piece] {
        let colors = [Palette.cheek, Palette.rose, Palette.gold, Palette.mint, Palette.sky, .white]
        return (0..<110).map { _ in
            Piece(
                x0: Double.random(in: -30...30),
                vx: Double.random(in: -4.5...4.5),
                vy: -Double.random(in: 4...15),
                size: Double.random(in: 4...10),
                spin: Double.random(in: -0.15...0.15),
                color: colors.randomElement() ?? .white,
                round: Double.random(in: 0...1) < 0.4
            )
        }
    }
}
