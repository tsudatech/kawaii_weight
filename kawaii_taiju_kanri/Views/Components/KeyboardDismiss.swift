//
//  KeyboardDismiss.swift
//  kawaii_taiju_kanri
//
//  入力欄の外をタップしたらキーボードを閉じる（体重・キャラの名前・メモ）。
//  ウィンドウ全体にタップの認識を1つだけ足す。タップそのものは下のボタンなどにもそのまま届く。
//

import SwiftUI
import UIKit

/// RootView の背景に置くと、そのウィンドウでキーボードの外をタップしたときに閉じるようになる
struct KeyboardDismissOnTapOutside: UIViewRepresentable {
    func makeUIView(context: Context) -> InstallerView { InstallerView() }
    func updateUIView(_ uiView: InstallerView, context: Context) {}

    final class InstallerView: UIView, UIGestureRecognizerDelegate {
        private weak var installedWindow: UIWindow?
        private lazy var tap: UITapGestureRecognizer = {
            let t = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            // ボタンやスクロールへのタップを止めない
            t.cancelsTouchesInView = false
            t.delegate = self
            return t
        }()

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard let window, window !== installedWindow else { return }
            installedWindow?.removeGestureRecognizer(tap)
            window.addGestureRecognizer(tap)
            installedWindow = window
        }

        @objc private func dismissKeyboard() {
            installedWindow?.endEditing(true)
        }

        /// 入力欄そのものをタップしたときは閉じない（カーソルを動かせるように）
        func gestureRecognizer(_ g: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var v = touch.view
            while let view = v {
                if view is UITextField || view is UITextView { return false }
                v = view.superview
            }
            return true
        }

        /// ほかの操作（スクロール・ドラッグ）と同時に動いてよい
        func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }
    }
}
