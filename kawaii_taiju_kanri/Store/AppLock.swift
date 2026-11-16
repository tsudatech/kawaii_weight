//
//  AppLock.swift
//  kawaii_taiju_kanri
//
//  Face ID（Touch ID・パスコード）でアプリを開く。かわいい日記（kawaiidiary）の AppLockService と同じ考え方。
//  オンにすると、起動したときと、背景から戻ったときに持ち主かを確かめる。
//
//  ロック画面は、いちばん上の別の窓に出す（シェアのメニュー・確認ダイアログ・全画面広告など、
//  SwiftUI の画面の外に出るものの上にもかぶせるため）。
//  オン・オフは AppSettings.appLock（端末ごと・iCloud には預けない）。
//

import Combine
import LocalAuthentication
import SwiftUI
import UIKit

/// この端末で確かめられる手段（文言の出し分け用）
enum DeviceAuthMethod: Equatable {
    case faceID, touchID, opticID, passcode

    var label: String {
        switch self {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .opticID: "Optic ID"
        case .passcode: L("パスコード")
        }
    }
}

@MainActor
final class AppLock: ObservableObject {
    static let shared = AppLock()

    /// 中身をかくしているか
    @Published private(set) var isLocked: Bool

    /// ロックしてから、まだ自動で確かめに行っていないか。
    /// 確かめるダイアログが出ると画面が一度非アクティブになるので、
    /// 前面に戻るたびに確かめに行くと、取り消しても出つづけてしまう
    private var pendingPrompt: Bool
    private var isAuthenticating = false
    private var window: UIWindow?

    private init() {
        let enabled = WeightStore.shared.settings.appLock
        isLocked = enabled
        pendingPrompt = enabled
    }

    var isEnabled: Bool { WeightStore.shared.settings.appLock }

    /// この端末で確かめられる手段。パスコードも設定されていなければ nil
    var method: DeviceAuthMethod? {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return nil }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .passcode
        }
    }

    // MARK: - せってい

    /// 切りかえる。オンにするときもオフにするときも、本人であることを先に確かめる
    /// （ほかの人が勝手にロックを外したり、持ち主を閉め出したりできないように）
    func setEnabled(_ on: Bool) async {
        let store = WeightStore.shared
        guard on != store.settings.appLock else { return }
        guard method != nil else {
            store.showToast(L("パスコードが設定されていないので使えないよ"))
            return
        }
        guard await authenticate() else { return }
        store.settings.appLock = on
        store.showToast(on ? LF("%@でロックするよ", method?.label ?? L("パスコード")) : L("ロックをオフにしました"))
    }

    // MARK: - ロックと解除

    /// 背景に回ったときに呼ぶ。アプリの切りかえ画面にも中身が映らないよう、すぐにかぶせる
    func lock() {
        guard isEnabled else { return }
        // 入力中のキーボードは、ロックの窓より上に出るので閉じておく
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isLocked = true
        pendingPrompt = true
        syncWindow()
    }

    /// 画面ができたときに呼ぶ（起動直後は、窓を置くシーンがまだないため）
    func attach() {
        if isLocked && !isEnabled { isLocked = false }
        syncWindow()
    }

    /// ロック中で、まだ確かめに行っていなければ行く。前面に戻ったときと、ロック画面が出たときに呼ぶ
    func promptIfNeeded() async {
        guard isLocked, pendingPrompt, UIApplication.shared.applicationState == .active else { return }
        pendingPrompt = false
        await unlock()
    }

    /// ロック画面のボタンから
    func unlock() async {
        guard isLocked else { return }
        // ロックを入れたあとで端末のパスコードを外すと、確かめる手段がなくなる。
        // そのままだと二度と開けなくなるので、守りようがない状態として開ける
        guard method != nil else {
            setUnlocked()
            return
        }
        if await authenticate() { setUnlocked() }
    }

    private func setUnlocked() {
        isLocked = false
        syncWindow()
    }

    private func authenticate() async -> Bool {
        guard !isAuthenticating else { return false }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            // 生体認証に失敗したときはパスコードへ回れるよう、.deviceOwnerAuthentication にする
            return try await LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: L("記録を見るために、本人か確かめます"))
        } catch {
            return false
        }
    }

    #if DEBUG
    /// スクリーンショット用（--preview-shot lock）。ロック画面を出して、確かめるダイアログは出さない
    func showForPreview() {
        isLocked = true
        pendingPrompt = false
    }
    #endif

    // MARK: - ロック画面の窓

    private func syncWindow() {
        guard isLocked else {
            window?.isHidden = true
            window = nil
            return
        }
        guard window == nil else { return }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first else { return }
        let w = UIWindow(windowScene: scene)
        w.windowLevel = .alert + 1
        let host = UIHostingController(rootView: AppLockScreen(lock: self))
        host.view.backgroundColor = UIColor(Palette.paper)
        w.rootViewController = host
        w.isHidden = false
        window = w
    }
}

/// ロック中に中身をおおう画面
struct AppLockScreen: View {
    @ObservedObject var lock: AppLock

    var body: some View {
        ZStack {
            Palette.paper.ignoresSafeArea()
            VStack(spacing: 0) {
                Image("lg_sleepy").resizable().scaledToFit()
                    .frame(width: 130, height: 130)
                    .frame(width: 170, height: 170)
                    .background(Circle().fill(Palette.faceBG))
                    .padding(.bottom, 22)
                Text(L("ロックしています"))
                    .font(.ui(18, .black))
                    .foregroundStyle(Palette.ink)
                    .padding(.bottom, 6)
                Text(L("記録を見るには、本人か確かめてね"))
                    .font(.ui(13))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.bottom, 28)
                Button {
                    Task { await lock.unlock() }
                } label: {
                    Text(LF("%@で開く", lock.method?.label ?? L("パスコード")))
                }
                .buttonStyle(.primary)
                .frame(width: 240)
            }
            .padding(.horizontal, 24)
        }
        // 出たところで一度だけ確かめに行く。取り消したらボタンから
        .task { await lock.promptIfNeeded() }
    }
}
